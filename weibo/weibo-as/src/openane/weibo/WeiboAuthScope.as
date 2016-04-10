package openane.weibo {
public class WeiboAuthScope {
    public static const ALL:String = "all";
    public static const EMAIL:String = "email";
    public static const DIRECT_MESSAGES_READ:String = "direct_messages_read";
    public static const DIRECT_MESSAGES_WRITE:String = "direct_messages_write";
    public static const INVITATION_WRITE:String = "invitation_write";
    public static const FRIENDSHIPS_GROUPS_READ:String = "friendships_groups_read";
    public static const FRIENDSHIPS_GROUPS_WRITE:String = "friendships_groups_write";
    public static const STATUSES_TO_ME_READ:String = "statuses_to_me_read";
    public static const FOLLOW_APP_OFFICIAL_MICROBLOG:String = "follow_app_official_microblog";

    public static function createScope(email:Boolean = false,
                                       directMessagesRead:Boolean = false,
                                       directMessagesWrite:Boolean = false,
                                       invitationWrite:Boolean = false,
                                       friendshipsGroupsRead:Boolean = false,
                                       friendshipsGroupsWrite:Boolean = false,
                                       statusesToMeRead:Boolean = false,
                                       followAppOfficialMicroblog:Boolean = false):String {
        var scope:Array = [];

        if (email) {
            scope.push(EMAIL);
        }

        if (directMessagesRead) {
            scope.push(DIRECT_MESSAGES_READ);
        }

        if (directMessagesWrite) {
            scope.push(DIRECT_MESSAGES_WRITE);
        }

        if (invitationWrite) {
            scope.push(INVITATION_WRITE);
        }

        if (friendshipsGroupsRead) {
            scope.push(FRIENDSHIPS_GROUPS_READ);
        }

        if (friendshipsGroupsWrite) {
            scope.push(FRIENDSHIPS_GROUPS_WRITE);
        }

        if (statusesToMeRead) {
            scope.push(STATUSES_TO_ME_READ);
        }

        if (followAppOfficialMicroblog) {
            scope.push(FOLLOW_APP_OFFICIAL_MICROBLOG);
        }

        return scope.join(",");
    }
}
}
