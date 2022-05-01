global function TargetPracticeInit

entity target;
int score = 0;

void function TargetPracticeInit() {
	//PrecacheModel( $"models/creatures/prowler/r2_prowler.mdl" )
	AddCallback_OnPlayerRespawned( OnPlayerRespawned );
	AddCallback_OnNPCKilled( OnNPCKilled );
}

/*	Marvin will appear next to the first player to spawn
*/
void function OnPlayerRespawned( entity player ) {
	//foreach ( entity weapon in player.GetMainWeapons() ) player.TakeWeaponNow( weapon.GetWeaponClassName() );
	//foreach ( entity weapon in player.GetOffhandWeapons() ) player.TakeWeaponNow( weapon.GetWeaponClassName() );
	//TakeAllWeapons(player);
	//player.GiveWeapon( "mp_weapon_peacekraber" )
	//thread SpawnDecoys_Threaded(player);

	if (!IsAlive(target)) {
		// If target died from fall damage, restore previous boss
		entity oldBoss;
		if (player == target) oldBoss = target.GetBossPlayer();

		// Create new target entity
		target = CreateMarvin(TEAM_UNASSIGNED, player.GetOrigin(), player.GetAngles());

		// Set ownership if possible
		if (IsValidPlayer(oldBoss)) target.SetBossPlayer(oldBoss);
		else if (IsValidPlayer(player)) target.SetBossPlayer(player);

		//if (IsValidPlayer(target.GetBossPlayer())) NPCFollowsPlayer(target, target.GetBossPlayer());

		target.SetMaxHealth( 99999 )
		target.SetHealth( 99999 );
		DispatchSpawn(target);
		AddEntityCallback_OnDamaged( target, OnDamaged );
	}
}


void function OnDamaged( entity victim, var damageInfo ) {
	if (victim != target) return;

	entity player = DamageInfo_GetAttacker( damageInfo );
	if (!IsValidPlayer(player)) return;
	//EmitSoundOnEntity( victim, "Weapon_Vortex_Gun.ExplosiveWarningBeep" );


	if (!victim.IsOnGround()) score++;
	else score = 1;
	SendHudMessageToAll("\n\n\n\n\n\n\n\n" + score.tostring(), 0.4985, 0.4751, 240, 182, 27, 255, 0, 5, 5)

	// Give unlimited ammo if only one player in the server
	if (GetPlayerArray().len() <= 1) RestockPlayerAmmo(player, true);

	victim.SetHealth(victim.GetMaxHealth());
	//Chat_ServerBroadcast(DamageInfo_GetDamage(damageInfo).tostring());

	// Move target in a random direction
	int sign = RandomIntRange(0, 2);
	if (sign == 0) sign--;
	victim.SetVelocity(AnglesToRight( player.EyeAngles() ) * sign * RandomFloatRange(300,500) + <0, 0, RandomFloatRange(225,325) + DamageInfo_GetDamage(damageInfo) * 2>);
	victim.SetBossPlayer(player);

	victim.SetAngles(<0, RandomFloatRange(-360,360), 0>);

	//NPCFollowsPlayer(victim, player);

	/*
	vector refAngles = GetRefAnglesBetweenEnts( victim, player )
	refAngles = <0,refAngles.y,0>
	vector fwd = AnglesToForward( refAngles )
	//fwd *= -1
	vector targetAngles = VectorToAngles( fwd )
	target.SetAngles( targetAngles )
	*/

	//thread PlayAnim( target, "mv_turret_repair_A_idle" )
}

void function OnNPCKilled( entity victim, entity player, var damageInfo) {
	if (victim != target) return;
	victim.MakeInvisible();
	OnPlayerRespawned( victim );
}
