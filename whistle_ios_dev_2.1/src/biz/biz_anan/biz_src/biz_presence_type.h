#pragma once

namespace biz
{
enum KPresenceType
{
	kptOnline,
	kptAway,
	kptBusy,
	kptOffline,
	kptAndroid,
	kptIOS,
	kptInvisible,
	kptInvalid
};

enum USrole
{
	RNone,                       /**< Not present in room. */
	RVisitor,                    /**< The user visits a room. */
	RParticipant,                /**< The user has voice in a moderatd room. */
	RModerator,                  /**< The user is a room moderator. */
	RInvalid                     /**< Invalid role. */
};

enum USAffiliation
{
	AFNone,                /**< No affiliation with the room. */
	AFOutcast,             /**< The user has been banned from the room. */
	AFMember,              /**< The user is a member of the room. */
	AFOwner,               /**< The user is a room owner. */
	AFAdmin,               /**< The user is a room admin. */
	AFInvalid              /**< Invalid affiliation. */
};

}; // biz