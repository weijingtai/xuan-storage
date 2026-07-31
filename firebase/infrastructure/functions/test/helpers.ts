const store = new Map<string, Map<string, Record<string, any>>>();

let idCounter = 0;
function autoId(): string {
  idCounter++;
  return `auto_${idCounter}_${Date.now().toString(36)}`;
}

function getColl(name: string): Map<string, Record<string, any>> {
  if (!store.has(name)) store.set(name, new Map());
  return store.get(name)!;
}

export function clearStore(): void {
  store.clear();
  idCounter = 0;
}

export function dumpStore(): Record<string, Record<string, any>[]> {
  const result: Record<string, Record<string, any>[]> = {};
  for (const [coll, docs] of store) {
    result[coll] = [];
    for (const [id, data] of docs) {
      result[coll].push({ id, ...data });
    }
  }
  return result;
}

function normalizeDocId(id: string | undefined): string {
  return id || autoId();
}

function toDate(val: any): Date | null {
  if (val === null || val === undefined) return null;
  if (val instanceof Date) return val;
  if (val.toDate && typeof val.toDate === 'function') return val.toDate();
  if (typeof val === 'string') return new Date(val);
  return null;
}

class MockDocRef {
  constructor(
    public _coll: string,
    public _id: string,
  ) {}

  get id(): string {
    return this._id;
  }

  get path(): string {
    return `${this._coll}/${this._id}`;
  }

  async get() {
    const coll = getColl(this._coll);
    const data = coll.get(this._id);
    return {
      exists: data !== undefined,
      id: this._id,
      data: () => data ?? null,
      get: (field: string) => data?.[field],
      ref: this,
    };
  }

  async set(data: any) {
    const coll = getColl(this._coll);
    const sanitized: Record<string, any> = {};
    for (const [k, v] of Object.entries(data)) {
      const val = v as any;
      sanitized[k] = val?._isFieldValue ? val._value : val;
    }
    coll.set(this._id, sanitized);
  }

  async update(data: any) {
    const coll = getColl(this._coll);
    const existing = coll.get(this._id);
    if (!existing) return;
    const sanitized: Record<string, any> = {};
    for (const [k, v] of Object.entries(data)) {
      const val = v as any;
      sanitized[k] = val?._isFieldValue ? val._value : val;
    }
    coll.set(this._id, { ...existing, ...sanitized });
  }

  async delete() {
    const coll = getColl(this._coll);
    coll.delete(this._id);
  }
}

function applyFilters(
  docs: Array<{ id: string; data: Record<string, any> }>,
  filters: Array<{ field: string; op: string; value: any }>,
): Array<{ id: string; data: Record<string, any> }> {
  return docs.filter(({ data }) => {
    return filters.every((f) => {
      const docVal = data[f.field];
      if (f.op === '==') {
        if (docVal === null && f.value === null) return true;
        if (docVal === undefined && f.value === null) return true;
        return docVal === f.value;
      }
      if (f.op === '<') return docVal < f.value;
      if (f.op === '<=') return docVal <= f.value;
      if (f.op === '>') return docVal > f.value;
      if (f.op === '>=') return docVal >= f.value;
      if (f.op === '>=') return docVal >= f.value;
      return false;
    });
  });
}

class MockQuery {
  private _filters: Array<{ field: string; op: string; value: any }> = [];
  private _limitVal: number | null = null;

  constructor(private _coll: string) {}

  where(field: string, op: string, value: any): MockQuery {
    this._filters.push({ field, op, value });
    return this;
  }

  limit(n: number): MockQuery {
    this._limitVal = n;
    return this;
  }

  async get() {
    const coll = getColl(this._coll);
    const allDocs: Array<{ id: string; data: Record<string, any> }> = [];
    for (const [id, data] of coll) {
      allDocs.push({ id, data });
    }

    let filtered = applyFilters(allDocs, this._filters);

    if (this._limitVal !== null && this._limitVal < filtered.length) {
      filtered = filtered.slice(0, this._limitVal);
    }

    const docs = filtered.map(
      ({ id, data }) => ({
        id,
        exists: true,
        data: () => data,
        get: (field: string) => data?.[field],
        ref: new MockDocRef(this._coll, id),
      }),
    );

    return {
      empty: docs.length === 0,
      size: docs.length,
      docs,
      forEach: (fn: Function) => docs.forEach((d) => fn(d)),
    };
  }
}

export function createAdminMock() {
  const fieldValue = {
    serverTimestamp: () => ({ _isFieldValue: true, _value: new Date().toISOString() }),
    increment: (n: number) => ({ _isFieldValue: true, _value: n }),
    arrayUnion: (...args: any[]) => ({ _isFieldValue: true, _value: args }),
    arrayRemove: (...args: any[]) => ({ _isFieldValue: true, _value: args }),
    delete: () => ({ _isFieldValue: true, _value: '__delete__' }),
  };

  const mockFirestoreInstance: any = {
    collection: (name: string) => new MockCollectionRef(name),
    runTransaction: async (fn: Function) => {
      const tx = new MockTransaction();
      const result = await fn(tx);
      tx._commit();
      return result;
    },
    batch: () => new MockWriteBatch(),
  };

  mockFirestoreInstance.FieldValue = fieldValue;

  const mockFirestore: any = () => mockFirestoreInstance;
  mockFirestore.FieldValue = fieldValue;

  const mockMessaging: any = {
    sendEachForMulticast: async () => ({ responses: [], successCount: 0, failureCount: 0 }),
    send: async () => 'mock-message-id',
  };

  const mockAuth: any = {
    getUser: async (uid: string) => ({ uid, email: `${uid}@test.com` }),
    verifyIdToken: async () => ({ uid: 'test-uid' }),
  };

  const mockStorage: any = {
    bucket: () => ({
      file: (path: string) => ({
        delete: async () => {},
        getMetadata: async () => ({ metadata: {} }),
      }),
    }),
  };

  let appCount = 0;

  return {
    initializeApp: () => {
      appCount++;
    },
    apps: [],
    appCount: 0,
    firestore: mockFirestore,
    auth: () => mockAuth,
    messaging: () => mockMessaging,
    storage: () => mockStorage,
    credential: {
      cert: () => ({}),
      applicationDefault: () => ({}),
      refreshToken: () => ({}),
    },
  };
}

class MockCollectionRef {
  constructor(private _name: string) {}

  doc(id?: string): MockDocRef {
    return new MockDocRef(this._name, normalizeDocId(id));
  }

  where(field: string, op: string, value: any): MockQuery {
    return new MockQuery(this._name).where(field, op, value);
  }

  async get() {
    return new MockQuery(this._name).get();
  }
}

class MockTransaction {
  private _ops: Array<() => void> = [];

  async get(docRef: MockDocRef) {
    const coll = getColl(docRef._coll);
    const data = coll.get(docRef._id);
    return {
      exists: data !== undefined,
      id: docRef._id,
      data: () => data ?? null,
      get: (field: string) => data?.[field],
      ref: docRef,
    };
  }

  async set(docRef: MockDocRef, data: any) {
    this._ops.push(() => {
      const sanitized: Record<string, any> = {};
      for (const [k, v] of Object.entries(data)) {
        const val = v as any;
        sanitized[k] = val?._isFieldValue ? val._value : val;
      }
      const coll = getColl(docRef._coll);
      coll.set(docRef._id, sanitized);
    });
  }

  async update(docRef: MockDocRef, data: any) {
    this._ops.push(() => {
      const sanitized: Record<string, any> = {};
      for (const [k, v] of Object.entries(data)) {
        const val = v as any;
        sanitized[k] = val?._isFieldValue ? val._value : val;
      }
      const coll = getColl(docRef._coll);
      const existing = coll.get(docRef._id);
      if (existing) {
        coll.set(docRef._id, { ...existing, ...sanitized });
      }
    });
  }

  async delete(docRef: MockDocRef) {
    this._ops.push(() => {
      const coll = getColl(docRef._coll);
      coll.delete(docRef._id);
    });
  }

  _commit() {
    for (const op of this._ops) {
      op();
    }
  }
}

class MockWriteBatch {
  private _ops: Array<() => void> = [];

  set(docRef: MockDocRef, data: any) {
    this._ops.push(() => {
      const sanitized: Record<string, any> = {};
      for (const [k, v] of Object.entries(data)) {
        const val = v as any;
        sanitized[k] = val?._isFieldValue ? val._value : val;
      }
      const coll = getColl(docRef._coll);
      coll.set(docRef._id, sanitized);
    });
    return this;
  }

  update(docRef: MockDocRef, data: any) {
    this._ops.push(() => {
      const sanitized: Record<string, any> = {};
      for (const [k, v] of Object.entries(data)) {
        const val = v as any;
        sanitized[k] = val?._isFieldValue ? val._value : val;
      }
      const coll = getColl(docRef._coll);
      const existing = coll.get(docRef._id);
      if (existing) {
        coll.set(docRef._id, { ...existing, ...sanitized });
      }
    });
    return this;
  }

  delete(docRef: MockDocRef) {
    this._ops.push(() => {
      const coll = getColl(docRef._coll);
      coll.delete(docRef._id);
    });
    return this;
  }

  async commit() {
    for (const op of this._ops) {
      op();
    }
  }
}
