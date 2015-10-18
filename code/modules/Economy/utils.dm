////////////////////////
// Ease-of-use
//
// Economy system is such a mess of spaghetti.  This should help.
////////////////////////

/proc/get_money_account(var/account_number, var/from_z=-1)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/get_money_account() called tick#: [world.time]")
	for(var/obj/machinery/account_database/DB in account_DBs)
		if(from_z > -1 && DB.z != from_z) continue
		if((DB.stat & NOPOWER) || !DB.activated ) continue
		var/datum/money_account/acct = DB.get_account(account_number)
		if(!acct) continue
		return acct


/obj/proc/get_card_account(var/obj/item/weapon/card/I, var/mob/user=null, var/terminal_name="", var/transaction_purpose="", var/require_pin=0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/proc/get_card_account() called tick#: [world.time]")
	if(terminal_name=="")
		terminal_name=src.name
	if (istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = I
		var/attempt_pin=0
		var/datum/money_account/D = get_money_account(C.associated_account_number)
		if(require_pin && user)
			attempt_pin = input(user,"Enter pin code", "Transaction") as num
			if(D.remote_access_pin != attempt_pin)
				return null
		if(D)
			return D

/mob/proc/get_worn_id_account(var/require_pin=0, var/mob/user=null)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/proc/get_worn_id_account() called tick#: [world.time]")
	if(ishuman(src))
		var/obj/item/weapon/card/id/I = get_id_card()
		var/attempt_pin=0
		if(!istype(I))
			return null
		var/datum/money_account/D = get_money_account(I.associated_account_number)
		if(require_pin && user)
			attempt_pin = input(user,"Enter pin code", "Transaction") as num
			if(D.remote_access_pin != attempt_pin)
				return null
		return D
	else if(issilicon(src))
		return station_account

/datum/money_account/proc/fmtBalance()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/money_account/proc/fmtBalance() called tick#: [world.time]")
	return "$[num2septext(money)]"

/datum/money_account/proc/charge(var/transaction_amount,var/datum/money_account/dest,var/transaction_purpose, var/terminal_name="", var/terminal_id=0, var/dest_name = "UNKNOWN")
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/money_account/proc/charge() called tick#: [world.time]")
	if(transaction_amount <= money)
		//transfer the money
		money -= transaction_amount
		if(dest)
			dest.money += transaction_amount

		//create entries in the two account transaction logs
		var/datum/transaction/T
		if(dest)
			T = new()
			T.target_name = owner_name
			if(terminal_name!="")
				T.target_name += " (via [terminal_name])"
			T.purpose = transaction_purpose
			T.amount = "[transaction_amount]"
			T.source_terminal = terminal_name
			T.date = current_date_string
			T.time = worldtime2text()
			dest.transaction_log.Add(T)
		//
		T = new()
		T.target_name = (!dest) ? dest_name : dest.owner_name
		if(terminal_name!="")
			T.target_name += " (via [terminal_name])"
		T.purpose = transaction_purpose
		if(transaction_amount < 0)
			T.amount = "[-1*transaction_amount]"
		else
			T.amount = "-[transaction_amount]"
		T.source_terminal = terminal_name
		T.date = current_date_string
		T.time = worldtime2text()
		transaction_log.Add(T)
		return 1
	else
		usr << "\icon[src]<span class='warning'>You don't have that much money!</span>"
		return 0
