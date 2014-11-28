/*
This is /vg/'s nerf for hulk.  Feel free to steal it.

Obviously, requires DNA2.
*/

// When hulk was first applied (world.time).
/mob/living/carbon/human/var/hulk_time=0

// In decaseconds.
#define HULK_DURATION 300 // How long the effects last
#define HULK_COOLDOWN 600 // How long they must wait to hulk out.

/datum/dna/gene/basic/grant_spell/hulk
	name = "Hulk"
	desc = "Allows the subject to become the motherfucking Hulk."
	activation_messages = list("Your muscles hurt.")
	deactivation_messages = list("Your muscles quit tensing.")
	flags = GENE_UNNATURAL // Do NOT spawn on roundstart.

	spelltype = /atom/movable/spell/targeted/genetic/hulk

/datum/dna/gene/basic/grant_spell/hulk/New()
	..()
	block = HULKBLOCK

/datum/dna/gene/basic/grant_spell/hulk/can_activate(var/mob/M,var/flags)
	// Can't be big AND small.
	if(M_DWARF in M.mutations)
		return 0
	return ..(M,flags)

/datum/dna/gene/basic/grant_spell/hulk/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	if(M_HULK in M.mutations)
		if(fat)
			return "hulk_[fat]_s"
		else
			return "hulk_[g]_s"
	return 0

/datum/dna/gene/basic/grant_spell/hulk/OnMobLife(var/mob/living/carbon/human/M)
	if(!istype(M)) return
	if(M_HULK in M.mutations)
		var/timeleft=M.hulk_time - world.time
		if(M.health <= 25 || timeleft <= 0)
			M.hulk_time=0 // Just to be sure.
			M.mutations.Remove(M_HULK)
			//M.dna.SetSEState(HULKBLOCK,0)
			M.update_mutations()		//update our mutation overlays
			M.update_body()
			M << "\red You suddenly feel very weak."
			M.Weaken(3)
			M.emote("collapse")

/atom/movable/spell/targeted/genetic/hulk
	name = "Hulk Out"
	panel = "Mutant Powers"
	range = -1
	include_user = 1

	charge_type = "recharge"
	charge_max = HULK_COOLDOWN

	duration = HULK_DURATION

	clothes_req = 0
	stat_allowed = 0

	invocation_type = "none"

/atom/movable/spell/targeted/genetic/hulk/New()
	desc = "Get mad!  For [duration/10] seconds, anyway."
	..()

/atom/movable/spell/targeted/genetic/hulk/cast(list/targets, mob/user)
	if (istype(user.loc,/mob))
		usr << "\red You can't hulk out right now!"
		return
	for(var/mob/living/carbon/human/M in targets)
		M.hulk_time = world.time + src.duration
		M.mutations.Add(M_HULK)
		M.update_mutations()		//update our mutation overlays
		M.update_body()
		//M.say(pick("",";")+pick("HULK MAD","YOU MADE HULK ANGRY")) // Just a note to security.
		message_admins("[key_name(M)] has hulked out! ([formatJumpTo(M)])")
	return