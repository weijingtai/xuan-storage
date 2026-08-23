"""Python FaaS 入口。与 TS 版并存，共用同一 Firebase 项目与 Firestore。"""

from xuan.handlers.bookmarks import set_bookmark_py  # noqa: F401
from xuan.handlers.likes import set_like_py  # noqa: F401
from xuan.handlers.profiles import update_my_profile_py  # noqa: F401
from xuan.handlers.posts import (  # noqa: F401
    create_post_py,
    edit_post_py,
    tombstone_post_py,
)
from xuan.handlers.replies import (  # noqa: F401
    create_discussion_reply_py,
    create_root_reply_py,
    delete_reply_py,
    edit_reply_py,
)

from xuan.handlers.conversations import (  # noqa: F401
    block_user_py,
    respond_dm_request_py,
    send_dm_request_py,
    send_message_py,
    unblock_user_py,
)
from xuan.handlers.guest_replies import (  # noqa: F401
    get_guest_representative_replies_py,
)

from xuan.handlers.identity_callable import resolve_my_identity_py  # noqa: F401
from xuan.handlers.outcome_feedback import (  # noqa: F401
    revoke_outcome_feedback_py,
    set_outcome_feedback_py,
)
from xuan.handlers.reputation import recalculate_reputation_py  # noqa: F401
from xuan.handlers.verifications import (  # noqa: F401
    revoke_verification_py,
    verify_root_reply_py,
)
from xuan.handlers.fcm import (  # noqa: F401
    register_fcm_token_py,
    unregister_fcm_token_py,
)
from xuan.handlers.moderation import report_content_py  # noqa: F401
from xuan.handlers.media import (  # noqa: F401
    cleanup_orphan_media_py,
    on_media_uploaded_py,
)
from xuan.handlers.notifications import on_outbox_created_py  # noqa: F401
from xuan.handlers.playground_rest import (  # noqa: F401
    playground_bookmarks_py,
    playground_feed_py,
    playground_likes_py,
    playground_posts_py,
    playground_posts_write_py,
    playground_profile_py,
    playground_replies_write_py,
    playground_verifications_write_py,
    playground_outcome_feedback_write_py,
)

# 函数名统一加 `_py` 后缀：切换期两个版本同时部署在一个项目里，
# 同名会互相覆盖。客户端通过配置决定调哪一个。


