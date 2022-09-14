#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_score;

init()
{
	startInit(); //precaching models
	level thread onPlayerConnect(); //on connect
	thread initServerDvars(); //initilize server dvars (credit JezuzLizard)
	thread startCustomPerkMachines(); //custom perk machines
	level.afterlife_give_loadout = maps/mp/gametypes_zm/_clientids::give_afterlife_loadout; //override function that gives loadout back to the player.
	level.playerDamageStub = level.callbackplayerdamage; //damage callback for phd flopper
	level.callbackplayerdamage = ::phd_flopper_dmg_check; //more damage callback stuff. everybody do the flop
	//level.using_solo_revive = 0; //disables solo revive, fixing only 3 revives per game.
	//level.is_forever_solo_game = 0; //changes afterlives on motd from 3 to 1
	isTown(); //jezuzlizard's fix for tombstone :)
}

onPlayerConnect()
{
	level endon( "end_game" );
    self endon( "disconnect" );
	for (;;)
	{
		level waittill( "connected", player );
		
		player thread [[level.givecustomcharacters]]();
		player thread doPHDdive();
		player thread onPlayerSpawned();
		player thread onPlayerDowned();
		player thread onPlayerRevived();
		player thread spawnIfRoundOne(); //force spawns if round 1. no more spectating one player on round 1
	}
}

onPlayerSpawned()
{
	level endon( "end_game" );
    self endon( "disconnect" );
	for(;;)
	{
		self waittill( "spawned_player" );
	}
}

startCustomPerkMachines()
{
	if(level.disableAllCustomPerks == 0)
	{
		if(getDvar("mapname") == "zm_prison") //mob of the dead
		{
			if(level.enablePHDFlopper == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_deadshot", "p6_zm_al_vending_nuke_on", "PHD Flopper", 3000, (2427.45, 10048.4, 1704.13), "PHD_FLOPPER", (0, 0, 0) );
			if(level.enableStaminUp == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_deadshot", "p6_zm_al_vending_doubletap2_on", "Stamin-Up", 2000, (-339.642, -3915.84, -8447.88), "specialty_longersprint", (0, 270, 0) );
			if(level.enableMuleKick == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_jugg", "p6_zm_al_vending_three_gun_on", "Mule Kick", 3000, ( -627.334, 6972.6, 64.125 ), "specialty_additionalprimaryweapon", (0, 90, 0) );
		}
		else if(getDvar("mapname") == "zm_highrise") //die rise
		{
			if(level.enablePHDFlopper == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_whoswho", "zombie_vending_nuke_on_lo", "PHD Flopper", 3000, (1260.3, 2736.36, 3047.49), "PHD_FLOPPER", (0, 0, 0) );
			if(level.enableDeadshot == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_whoswho", "zombie_vending_revive", "Deadshot Daiquiri", 1500, (3690.54, 1932.36, 1420), "specialty_deadshot", (-15, 0, 0) );
			if(level.enableStaminUp == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_revive", "zombie_vending_doubletap2", "Stamin-Up", 2000, (1704, -35, 1120.13), "specialty_longersprint", (0, -30, 0) );
		}
		else if(getDvar("mapname") == "zm_buried") //buried
		{
			if(level.enablePHDFlopper == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_marathon", "zombie_vending_jugg", "PHD Flopper", 3000, (2631.73, 304.165, 240.125), "PHD_FLOPPER", (5, 0, 0) );
			if(level.enableDeadshot == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_marathon", "zombie_vending_revive", "Deadshot Daiquiri", 1500, (1055.18, -1055.55, 201), "specialty_deadshot", (3, 270, 0) );
		}
		else if(getDvar("mapname") == "zm_nuked") //nuketown
		{
			if(level.enablePHDFlopper == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_revive", "zombie_vending_jugg", "PHD Flopper", 3000, (683, 727, -56), "PHD_FLOPPER", (5, 250, 0) );
			if(level.enableDeadshot == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_jugg", "zombie_vending_revive", "Deadshot Daiquiri", 1500, (747, 356, 91), "specialty_deadshot", (0, 330, 0) );
			if(level.enableStaminUp == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_revive", "zombie_vending_doubletap2", "Stamin-Up", 2000, (-638, 268, -54), "specialty_longersprint", (0, 165, 0) );
			if(level.enableMuleKick == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_jugg", "zombie_vending_sleight", "Mule Kick", 3000, (-953, 715, 83), "specialty_additionalprimaryweapon", (0, 75, 0) );
		}

		else if( getDvar("mapname") == "zm_transit")
		{
			if(level.enablePHDFlopper == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_revive", "zombie_vending_jugg", "PHD Flopper", 3000, ( 419.641, 291.335, -37.4571 ), "PHD_FLOPPER", (0, 90, 0) );
			if(level.enableDeadshot == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_jugg", "zombie_vending_revive", "Deadshot Daiquiri", 1500, ( 1853.77, 680.355, -55.875 ), "specialty_deadshot", (0, 0, 0) );
			if(level.enableMuleKick == 1)
				level thread CustomPerkMachine( "zombie_perk_bottle_jugg", "zombie_vending_sleight", "Mule Kick", 3000, ( 1855.43, -810.34, -55.875 ), "specialty_additionalprimaryweapon", (0, 180, 0) );
		}
	}
}

onPlayerDowned()
{
	self endon("disconnect");
	level endon("end_game");
	
	for(;;)
	{
		self waittill_any( "player_downed", "fake_death", "entering_last_stand");
    		self unsetperk( "specialty_additionalprimaryweapon" ); //removes the mulekick perk functionality
		self unsetperk( "specialty_longersprint" ); //removes the staminup perk functionality
		self unsetperk( "specialty_deadshot" ); //removes the deadshot perk functionality
		self.hasPHD = undefined; //resets the flopper variable
		self.hasMuleKick = undefined; //resets the mule kick variable
		self.hasStaminUp = undefined; //resets the staminup variable
		self.hasDeadshot = undefined; //resets the deadshot variable
    		self.icon1 Destroy();self.icon1 = undefined; //deletes the perk icons and resets the variable
    		self.icon2 Destroy();self.icon2 = undefined; //deletes the perk icons and resets the variable
    		self.icon3 Destroy();self.icon3 = undefined; //deletes the perk icons and resets the variable
    		self.icon4 Destroy();self.icon4 = undefined; //deletes the perk icons and resets the variable
	}
}

doPHDdive() //credit to extinct. just edited to add self.hasPHD variable
{
	self endon("disconnect");
	level endon("end_game");
	
	for(;;)
	{
		if(isDefined(self.divetoprone) && self.divetoprone)
		{
			if(self isOnGround() && isDefined(self.hasPHD))
			{
				if(level.script == "zm_tomb" || level.script == "zm_buried")	
					explosionfx = level._effect["divetonuke_groundhit"];
				else
					explosionfx = loadfx("explosions/fx_default_explosion");
				self playSound("zmb_phdflop_explo");
				playfx(explosionfx, self.origin);
				self damageZombiesInRange(310, self, "kill");
				wait .3;
			}
		}
		wait .05;
	}
}

damageZombiesInRange(range, what, amount) //damage zombies for phd flopper
{
	enemy = getAiArray(level.zombie_team);
	foreach(zombie in enemy)
	{
		if(distance(zombie.origin, what.origin) < range)
		{
			if(amount == "kill")
				zombie doDamage(zombie.health * 2, zombie.origin, self);
			else
				zombie doDamage(amount, zombie.origin, self);
		}
	}
}

phd_flopper_dmg_check( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex ) //phdflopdmgchecker lmao
{
	if ( smeansofdeath == "MOD_SUICIDE" || smeansofdeath == "MOD_FALLING" || smeansofdeath == "MOD_PROJECTILE" || smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_EXPLOSIVE" )
	{
		if(isDefined(self.hasPHD)) //if player has phd flopper, dont damage the player
			return;
	}
	[[ level.playerDamageStub ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex );
}

CustomPerkMachine( bottle, model, perkname, cost, origin, perk, angles ) //custom perk system. orginal code from ZeiiKeN. edited to work for all maps and custom phd perk
{
	level endon( "end_game" );
	if(!isDefined(level.customPerkNum))
		level.customPerkNum = 1;
	else
		level.customPerkNum += 1;
	collision = spawn("script_model", origin);
    collision setModel("collision_geo_cylinder_32x128_standard");
    collision rotateTo(angles, .1);
	RPerks = spawn( "script_model", origin );
	RPerks setModel( model );
	RPerks rotateTo(angles, .1);
	level thread LowerMessage( "Custom Perks", "Hold ^3&&1 ^7for "+perkname+" [Cost: "+cost+"]" );
	trig = spawn("trigger_radius", origin, 1, 25, 25);
	trig SetCursorHint( "HINT_NOICON" );
	trig setLowerMessage( trig, "Custom Perks" );
	for(;;)
	{
		trig waittill("trigger", player);
		if(player useButtonPressed() && player.score >= cost)
		{
			wait .25;
			if(player useButtonPressed())
			{
				if(perk != "PHD_FLOPPER" && !player hasPerk(perk) || perk == "PHD_FLOPPER" && !isDefined(player.hasPHD))
				{
					player playsound( "zmb_cha_ching" ); //money shot
					player.score -= cost; //take points
					level.trig hide();
					player thread GivePerk( bottle, perk, perkname ); //give perk
					wait 2;
					level.trig show();
				}
				else
					player iprintln("You Already Have "+perkname+"!");
			}
		}
	}
}

GivePerk( model, perk, perkname )
{
	self DisableOffhandWeapons();
	self DisableWeaponCycling();
	weaponA = self getCurrentWeapon();
	weaponB = model;
	self GiveWeapon( weaponB );
	self SwitchToWeapon( weaponB );
	self waittill( "weapon_change_complete" );
	self EnableOffhandWeapons();
	self EnableWeaponCycling();
	self TakeWeapon( weaponB );
	self SwitchToWeapon( weaponA );
	self setperk( perk );
	self maps/mp/zombies/_zm_audio::playerexert( "burp" );
	self setblur( 4, 0.1 );
	wait 0.1;
	self setblur( 0, 0.1 );
	if(perk == "PHD_FLOPPER")
	{
		self.hasPHD = true;
		self thread drawCustomPerkHUD("specialty_doubletap_zombies", 0, (1, 0.25, 1));

	}
	else if(perk == "specialty_additionalprimaryweapon")
	{
		self.hasMuleKick = true;
		self thread drawCustomPerkHUD("specialty_fastreload_zombies", 0, (0, 0.7, 0));
	}
	else if(perk == "specialty_longersprint")
	{
		self.hasStaminUp = true;
		self thread drawCustomPerkHUD("specialty_juggernaut_zombies", 0, (1, 1, 0));
	}
	else if(perk == "specialty_deadshot")
	{
		self.hasDeadshot = true;
		self thread drawCustomPerkHUD("specialty_quickrevive_zombies", 0, (0.125, 0.125, 0.125));
	}
}

LowerMessage( ref, text )
{
	if( !IsDefined( level.zombie_hints ) )
		level.zombie_hints = [];
	PrecacheString( text );
	level.zombie_hints[ref] = text;
}

setLowerMessage( ent, default_ref )
{
	if( IsDefined( ent.script_hint ) )
		self SetHintString( get_zombie_hint( ent.script_hint ) );
	else
		self SetHintString( get_zombie_hint( default_ref ) );
}

drawshader( shader, x, y, width, height, color, alpha, sort )
{
	hud = newclienthudelem( self );
	hud.elemtype = "icon";
	hud.color = color;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.children = [];
	hud setparent( level.uiparent );
	hud setshader( shader, width, height );
	hud.x = x;
	hud.y = y;
	return hud;
}

drawCustomPerkHUD(perk, x, color, perkname) //perk hud thinking or whatever. probably not the best method but whatever lol
{
    if(!isDefined(self.icon1))
    {
    	x = -408;
    	if(getDvar("mapname") == "zm_buried")
    		self.icon1 = self drawshader( perk, x, 293, 24, 25, color, 100, 0 );
    	else
    		self.icon1 = self drawshader( perk, x, 320, 24, 25, color, 100, 0 );
    }
    else if(!isDefined(self.icon2))
    {
    	x = -378;
    	if(getDvar("mapname") == "zm_buried")
    		self.icon2 = self drawshader( perk, x, 293, 24, 25, color, 100, 0 );
    	else
    		self.icon2 = self drawshader( perk, x, 320, 24, 25, color, 100, 0 );
    }
    else if(!isDefined(self.icon3))
    {
    	x = -348;
    	if(getDvar("mapname") == "zm_buried")
    		self.icon3 = self drawshader( perk, x, 293, 24, 25, color, 100, 0 );
    	else
    		self.icon3 = self drawshader( perk, x, 320, 24, 25, color, 100, 0 );
    }
    else if(!isDefined(self.icon4))
    {
    	x = -318;
    	if(getDvar("mapname") == "zm_buried")
    		self.icon4 = self drawshader( perk, x, 293, 24, 25, color, 100, 0 );
    	else
    		self.icon4 = self drawshader( perk, x, 320, 24, 25, color, 100, 0 );
    }
}

LowerMessage( ref, text )
{
	if( !IsDefined( level.zombie_hints ) )
		level.zombie_hints = [];
	PrecacheString( text );
	level.zombie_hints[ref] = text;
}

setLowerMessage( ent, default_ref )
{
	if( IsDefined( ent.script_hint ) )
		self SetHintString( get_zombie_hint( ent.script_hint ) );
	else
		self SetHintString( get_zombie_hint( default_ref ) );
}

startInit()
{
	PrecacheModel("collision_geo_cylinder_32x128_standard");
	PrecacheModel("zombie_vending_jugg");
	PrecacheModel("zombie_perk_bottle_marathon");
	PrecacheModel("zombie_perk_bottle_whoswho");
	PrecacheModel("zombie_vending_nuke_on_lo");
	PrecacheModel("p6_zm_al_vending_pap_on");
	PrecacheModel("p6_anim_zm_buildable_pap");
	PrecacheModel("p6_zm_al_vending_pap_on");
	PrecacheModel("p6_zm_al_vending_jugg_on");
	PrecacheModel("p6_zm_al_vending_sleight_on");
	PrecacheModel("p6_zm_al_vending_doubletap2_on");	
	PrecacheModel("p6_zm_al_vending_ads_on");
	PrecacheModel("p6_zm_al_vending_nuke_on");
	PrecacheModel("p6_zm_al_vending_three_gun_on");
	PrecacheModel("p6_zm_al_vending_three_gun");
	PrecacheModel("zombie_vending_revive");
	PrecacheModel("zombie_vending_doubletap2");
	PrecacheModel("zombie_x2_icon");
	PrecacheModel("zombie_bomb");
	PrecacheModel("zombie_ammocan");
	PrecacheModel("zombie_x2_icon");
	PrecacheModel("zombie_skull");
	PrecacheShader("specialty_deadshot_zombies");
	preCacheShader("speciality_divetonuke_zombies");
	if(isDefined(level.player_out_of_playable_area_monitor))
		level.player_out_of_playable_area_monitor = false;
	level.pers_sniper_misses = 9999; //sniper perma perk! never lose it hahahahahahahahaha
	thread gscRestart(); //JezuzLizard fix sound stuff
    thread setPlayersToSpectator(); //JezuzLizard fix sound stuff
}

initServerDvars() //credits to JezuzLizard!!! This is a huge help in making this happen
{
	//sets the perk limit for all players
	level.perk_purchase_limit = getDvarIntDefault( "perkLimit", 4 );
	//enables midround hellhounds WARNING: causes permanent round pauses on maps that aren't bus depot, town or farm
	level.mixed_rounds_enabled = getDvarIntDefault( "midroundDogs", 0 );
	//enables the override for zombie health
	level.overrideZombieHealthPermanently = getDvarIntDefault( "overrideZombieHealthPermanently", 0 );
	//enables the health cap override so zombies health won't grow beyond the value indicated
	level.overrideZombieMaxHealth = getDvarIntDefault( "overrideZombieMaxHealth", 0 );
	//sets the maximum health zombie health will increase to 
	level.overrideZombieMaxHealthValue = getDvarIntDefault( "overrideZombieMaxHealthValue" , 150 );
	//set afterlives on mob to 1 like a normal coop match and sets the prices of doors on origins to be higher
	level.disableSoloMode = getDvarIntDefault( "disableSoloMode", 0 );
	if ( level.disableSoloMode )
	{
		level.is_forever_solo_game = undefined;
	}
	
	//Zombie_Vars:
	//The reason zombie_vars are first set to a var is because they don't reliably set when set directly to the value of a dvar
	//sets the zombie spawnrate; max is 0.08 
	level.zombieSpawnRate = getDvarFloatDefault( "zombieSpawnRate", 2 );
	level.zombie_vars[ "zombie_spawn_delay" ] = level.zombieSpawnRate;
	//sets whether spectators respawn at the end of the round
	level.customSpectatorsRespawn = getDvarIntDefault( "customSpectatorsRespawn", 1 );
	level.zombie_vars[ "spectators_respawn" ] = level.customSpectatorsRespawn;
	//unknown
	level.playerStartingLives = getDvarIntDefault( "playerStartingLives", 1 );
	level.zombie_vars[ "starting_lives" ] = level.playerStartingLives;
	//players turn into a zombie on death WARNING: buggy as can be and is missing assets
	level.shouldZombifyPlayer = getDvarIntDefault( "shouldZombifyPlayer", 0 );
	level.zombie_vars[ "zombify_player" ] = level.shouldZombifyPlayer;
	//sets the radius of emps explosion lower this to 1 to render emps useless
	level.empPerkExplosionRadius = getDvarIntDefault( "empPerkExplosionRadius", 420 );
	level.zombie_vars[ "emp_perk_off_range" ] = level.empPerkExplosionRadius;
	//sets the duration of emps on perks set to 0 for infiinite emps
	level.empPerkOffDuration = getDvarIntDefault( "empPerkOffDuration", 90 );
	level.zombie_vars[ "emp_perk_off_time" ] = level.empPerkOffDuration;
	//jugg health bonus
	level.juggHealthBonus = getDvarIntDefault( "juggHealthBonus", 160 );
	level.zombie_vars[ "zombie_perk_juggernaut_health" ] = level.juggHealthBonus;	
	//perma jugg health bonus 
	level.permaJuggHealthBonus = getDvarIntDefault( "permaJuggHealthBonus", 190 );
	level.zombie_vars[ "zombie_perk_juggernaut_health_upgrade" ] = level.permaJuggHealthBonus;
	//phd min explosion damage
	level.minPhdExplosionDamage = getDvarIntDefault( "minPhdExplosionDamage", 1000 );
	level.zombie_vars[ "zombie_perk_divetonuke_min_damage" ] = level.minPhdExplosionDamage;
	//phd max explosion damage
	level.maxPhdExplosionDamage = getDvarIntDefault( "maxPhdExplosionDamage", 5000 );
	level.zombie_vars[ "zombie_perk_divetonuke_max_damage" ] = level.maxPhdExplosionDamage;
	//phd explosion radius
	level.phdDamageRadius = getDvarIntDefault( "phdDamageRadius", 300 );
	level.zombie_vars[ "zombie_perk_divetonuke_radius" ] = level.phdDamageRadius;
	//disable custom perks
	level.disableAllCustomPerks = getDvarIntDefault( "disableAllCustomPerks", 0 );
	level.zombie_vars[ "disableAllCustomPerks" ] = level.disableAllCustomPerks;
	//enable custom phdflopper
	level.enablePHDFlopper = getDvarIntDefault( "enablePHDFlopper", 1 );
	level.zombie_vars[ "enablePHDFlopper" ] = level.enablePHDFlopper;
	//enable custom staminup
	level.enableStaminUp = getDvarIntDefault( "enableStaminUp", 1 );
	level.zombie_vars[ "enableStaminUp" ] = level.enableStaminUp;
	//enable custom deadshot
	level.enableDeadshot = getDvarIntDefault( "enableDeadshot", 1 );
	level.zombie_vars[ "enableDeadshot" ] = level.enableDeadshot;
	//enable custom mule kick
	level.enableMuleKick = getDvarIntDefault( "enableMuleKick", 1 );
	level.zombie_vars[ "enableMuleKick" ] = level.enableMuleKick;
}

gscRestart()
{
	level waittill( "end_game" );
	wait 15;
	map_restart( false );
}

setPlayersToSpectator()
{
	level.no_end_game_check = 1;
	wait 3;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( i == 0 )
		{
			i++;
		}
		players[ i ] setToSpectator();
		i++;
	}
	wait 5; 
	spawnAllPlayers();
}

setToSpectator()
{
    self.sessionstate = "spectator"; 
    if (isDefined(self.is_playing))
    {
        self.is_playing = false;
    }
}

spawnAllPlayers()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].sessionstate == "spectator" && isDefined( players[ i ].spectator_respawn ) )
		{
			players[ i ] [[ level.spawnplayer ]]();
			if ( level.script != "zm_tomb" || level.script != "zm_prison" || !is_classic() )
			{
				thread maps\mp\zombies\_zm::refresh_player_navcard_hud();
			}
		}
		i++;
	}
	level.no_end_game_check = 0;
}

spawnIfRoundOne() //spawn player
{
	wait 3;
	if ( self.sessionstate == "spectator" && level.round_number == 1 )
		self iprintln("Get ready to be spawned!");
	wait 5;
	if ( self.sessionstate == "spectator" && level.round_number == 1 )
	{
		self [[ level.spawnplayer ]]();
		if ( level.script != "zm_tomb" || level.script != "zm_prison" || !is_classic() )
			thread maps\mp\zombies\_zm::refresh_player_navcard_hud();
	}
}

solo_tombstone_removal()
{
	notify( "tombstone_on" );
}

turn_tombstone_on()
{
	while ( 1 )
	{
		machine = getentarray( "vending_tombstone", "targetname" );
		machine_triggers = getentarray( "vending_tombstone", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( level.machine_assets[ "tombstone" ].off_model );
			i++;
		}
		level thread do_initial_power_off_callback( machine, "tombstone" );
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "tombstone_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( level.machine_assets[ "tombstone" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "tombstone_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_scavenger_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "tombstone" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "tombstone" ].power_on_callback );
		}
		level waittill( "tombstone_off" );
		if ( isDefined( level.machine_assets[ "tombstone" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "tombstone" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
		players = get_players();
		_a1718 = players;
		_k1718 = getFirstArrayKey( _a1718 );
		while ( isDefined( _k1718 ) )
		{
			player = _a1718[ _k1718 ];
			player.hasperkspecialtytombstone = undefined;
			_k1718 = getNextArrayKey( _a1718, _k1718 );
		}
	}
}

perk_machine_spawn_init()
{
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( location != "default" && location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = ( level.scr_zm_ui_gametype + "_perks_" ) + location;
	pos = [];
	if ( isDefined( level.override_perk_targetname ) )
	{
		structs = getstructarray( level.override_perk_targetname, "targetname" );
	}
	else
	{
		structs = getstructarray( "zm_perk_machine", "targetname" );
	}
	_a3578 = structs;
	_k3578 = getFirstArrayKey( _a3578 );
	while ( isDefined( _k3578 ) )
	{
		struct = _a3578[ _k3578 ];
		if ( isDefined( struct.script_string ) )
		{
			tokens = strtok( struct.script_string, " " );
			_a3583 = tokens;
			_k3583 = getFirstArrayKey( _a3583 );
			while ( isDefined( _k3583 ) )
			{
				token = _a3583[ _k3583 ];
				if ( token == match_string )
				{
					pos[ pos.size ] = struct;
				}
				_k3583 = getNextArrayKey( _a3583, _k3583 );
			}
		}
		else pos[ pos.size ] = struct;
		_k3578 = getNextArrayKey( _a3578, _k3578 );
	}
	if ( !isDefined( pos ) || pos.size == 0 )
	{
		return;
	}
	precachemodel( "zm_collision_perks1" );
	i = 0;
	while ( i < pos.size )
	{
		perk = pos[ i ].script_noteworthy;
		if ( isDefined( perk ) && isDefined( pos[ i ].model ) )
		{
			use_trigger = spawn( "trigger_radius_use", pos[ i ].origin + vectorScale( ( 0, -1, 0 ), 30 ), 0, 40, 70 );
			use_trigger.targetname = "zombie_vending";
			use_trigger.script_noteworthy = perk;
			use_trigger triggerignoreteam();
			perk_machine = spawn( "script_model", pos[ i ].origin );
			perk_machine.angles = pos[ i ].angles;
			perk_machine setmodel( pos[ i ].model );
			if ( isDefined( level._no_vending_machine_bump_trigs ) && level._no_vending_machine_bump_trigs )
			{
				bump_trigger = undefined;
			}
			else
			{
				bump_trigger = spawn( "trigger_radius", pos[ i ].origin, 0, 35, 64 );
				bump_trigger.script_activated = 1;
				bump_trigger.script_sound = "zmb_perks_bump_bottle";
				bump_trigger.targetname = "audio_bump_trigger";
				if ( perk != "specialty_weapupgrade" )
				{
					bump_trigger thread thread_bump_trigger();
				}
			}
			collision = spawn( "script_model", pos[ i ].origin, 1 );
			collision.angles = pos[ i ].angles;
			collision setmodel( "zm_collision_perks1" );
			collision.script_noteworthy = "clip";
			collision disconnectpaths();
			use_trigger.clip = collision;
			use_trigger.machine = perk_machine;
			use_trigger.bump = bump_trigger;
			if ( isDefined( pos[ i ].blocker_model ) )
			{
				use_trigger.blocker_model = pos[ i ].blocker_model;
			}
			if ( isDefined( pos[ i ].script_int ) )
			{
				perk_machine.script_int = pos[ i ].script_int;
			}
			if ( isDefined( pos[ i ].turn_on_notify ) )
			{
				perk_machine.turn_on_notify = pos[ i ].turn_on_notify;
			}
			if ( perk == "specialty_scavenger" || perk == "specialty_scavenger_upgrade" )
			{
				use_trigger.script_sound = "mus_perks_tombstone_jingle";
				use_trigger.script_string = "tombstone_perk";
				use_trigger.script_label = "mus_perks_tombstone_sting";
				use_trigger.target = "vending_tombstone";
				perk_machine.script_string = "tombstone_perk";
				perk_machine.targetname = "vending_tombstone";
				if ( isDefined( bump_trigger ) )
				{
					bump_trigger.script_string = "tombstone_perk";
				}
			}
			if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].perk_machine_set_kvps ) )
			{
				[[ level._custom_perks[ perk ].perk_machine_set_kvps ]]( use_trigger, perk_machine, bump_trigger, collision );
			}
		}
		i++;
	}
}

isTown()
{
	if (isDefined(level.zombiemode_using_tombstone_perk) && level.zombiemode_using_tombstone_perk)
	{
		level thread perk_machine_spawn_init();
		thread solo_tombstone_removal();
		thread turn_tombstone_on();
	}
}
give_afterlife_loadout()
{

	self takeallweapons();
	loadout = self.loadout;
	primaries = self getweaponslistprimaries();
	if ( loadout.weapons.size > 1 || primaries.size > 1 )
	{
		foreach ( weapon in primaries )
		{
			self takeweapon( weapon );
		}
	}
	i = 0;
	while ( i < loadout.weapons.size )
	{

		if ( !isDefined( loadout.weapons[ i ] ) )
		{
			i++;

			continue;
		}
		if ( loadout.weapons[ i ][ "name" ] == "none" )
		{
			i++;

			continue;
		}
		self maps/mp/zombies/_zm_weapons::weapondata_give( loadout.weapons[ i ] );
		i++;
	}
	self setspawnweapon( loadout.weapons[ loadout.current_weapon ] );
	self switchtoweaponimmediate( loadout.weapons[ loadout.current_weapon ] );
	if ( isDefined( self get_player_melee_weapon() ) )
	{
		self giveweapon( self get_player_melee_weapon() );
	}
	self maps/mp/zombies/_zm_equipment::equipment_give( self.loadout.equipment );
	if ( isDefined( loadout.hasclaymore ) && loadout.hasclaymore && !self hasweapon( "claymore_zm" ) )
	{
		self giveweapon( "claymore_zm" );
		self set_player_placeable_mine( "claymore_zm" );
		self setactionslot( 4, "weapon", "claymore_zm" );
		self setweaponammoclip( "claymore_zm", loadout.claymoreclip );
	}
	if ( isDefined( loadout.hasemp ) && loadout.hasemp )
	{
		self giveweapon( "emp_grenade_zm" );
		self setweaponammoclip( "emp_grenade_zm", loadout.empclip );
	}
	if ( isDefined( loadout.hastomahawk ) && loadout.hastomahawk )
	{
		self giveweapon( self.current_tomahawk_weapon );
		self set_player_tactical_grenade( self.current_tomahawk_weapon );
		self setclientfieldtoplayer( "tomahawk_in_use", 1 );
	}
	self.score = loadout.score;
	perk_array = maps/mp/zombies/_zm_perks::get_perk_array( 1 );
	i = 0;
	while ( i < perk_array.size )
	{
		perk = perk_array[ i ];
		self unsetperk( perk );
		self set_perk_clientfield( perk, 0 );
		i++;
	}
	if (is_true(self.keep_perks))
	{
		if(is_true(self.hadphd))
		{
			self.hasphd = true;
			self.hadphd = undefined;
			self thread maps/mp/gametypes_zm/_clientids::drawCustomPerkHUD("specialty_doubletap_zombies", 0, (1, 0.25, 1));
		}
	}
	if ( isDefined( self.keep_perks ) && self.keep_perks && isDefined( loadout.perks ) && loadout.perks.size > 0 )
	{
		i = 0;
		while ( i < loadout.perks.size )
		{
			if ( self hasperk( loadout.perks[ i ] ) )
			{
				i++;
				continue;
			}
			if ( loadout.perks[ i ] == "specialty_quickrevive" && flag( "solo_game" ) )
			{
				level.solo_game_free_player_quickrevive = 1;
			}
			if ( loadout.perks[ i ] == "specialty_longersprint" )
			{
				self setperk( "specialty_longersprint" ); //removes the staminup perk functionality
				self.hasStaminUp = true; //resets the staminup variable
				self thread maps/mp/gametypes_zm/_clientids::drawCustomPerkHUD("specialty_juggernaut_zombies", 0, (1, 1, 0));
				arrayremovevalue( loadout.perks, "specialty_longersprint" );

				continue;
			}
			if ( loadout.perks[ i ] == "specialty_additionalprimaryweapon" )
			{
				self setperk( "specialty_additionalprimaryweapon"); //removes the deadshot perk functionality
				self.hasMuleKick = true; //resets the deadshot variable
				self thread maps/mp/gametypes_zm/_clientids::drawCustomPerkHUD("specialty_fastreload_zombies", 0, (0, 0.7, 0));
				arrayremovevalue( loadout.perks, "specialty_additionalprimaryweapon" );
				continue;
			}
			if ( loadout.perks[ i ] == "specialty_finalstand" )
			{
				i++;
				continue;
			}
			maps/mp/zombies/_zm_perks::give_perk( loadout.perks[ i ] );
			i++;
			wait 0.05;
		}
	}
	self.keep_perks = undefined;
	self set_player_lethal_grenade( self.loadout.lethal_grenade );
	if ( loadout.grenade > 0 )
	{
		curgrenadecount = 0;
		if ( self hasweapon( self get_player_lethal_grenade() ) )
		{
			self getweaponammoclip( self get_player_lethal_grenade() );
		}
		else
		{
			self giveweapon( self get_player_lethal_grenade() );
		}
		self setweaponammoclip( self get_player_lethal_grenade(), loadout.grenade + curgrenadecount );
	}

}
save_afterlife_loadout() //checked changed to match cerberus output
{
	primaries = self getweaponslistprimaries();
	currentweapon = self getcurrentweapon();
	self.loadout = spawnstruct();
	self.loadout.player = self;
	self.loadout.weapons = [];
	self.loadout.score = self.score;
	self.loadout.current_weapon = -1;
	index = 0;
	foreach ( weapon in primaries )
	{
		self.loadout.weapons[ index ] = maps/mp/zombies/_zm_weapons::get_player_weapondata( self, weapon );
		if ( weapon == currentweapon || self.loadout.weapons[ index ][ "alt_name" ] == currentweapon )
		{
			self.loadout.current_weapon = index;
		}
		index++;
	}
	self.loadout.equipment = self get_player_equipment();
	if ( isDefined( self.loadout.equipment ) )
	{
		self maps/mp/zombies/_zm_equipment::equipment_take( self.loadout.equipment );
	}
	if ( self hasweapon( "claymore_zm" ) )
	{
		self.loadout.hasclaymore = 1;
		self.loadout.claymoreclip = self getweaponammoclip( "claymore_zm" );
	}
	if ( self hasweapon( "emp_grenade_zm" ) )
	{
		self.loadout.hasemp = 1;
		self.loadout.empclip = self getweaponammoclip( "emp_grenade_zm" );
	}
	if ( self hasweapon( "bouncing_tomahawk_zm" ) || self hasweapon( "upgraded_tomahawk_zm" ) )
	{
		self.loadout.hastomahawk = 1;
		self setclientfieldtoplayer( "tomahawk_in_use", 0 );
	}
	self.loadout.perks = afterlife_save_perks( self );
	lethal_grenade = self get_player_lethal_grenade();
	if ( self hasweapon( lethal_grenade ) )
	{
		self.loadout.grenade = self getweaponammoclip( lethal_grenade );
	}
	else
	{
		self.loadout.grenade = 0;
	}
	self.loadout.lethal_grenade = lethal_grenade;
	self set_player_lethal_grenade( undefined );
}

afterlife_save_perks( ent ) //checked changed to match cerberus output
{
	perk_array = ent get_perk_array( 1 );
	foreach ( perk in perk_array )
	{
		ent unsetperk( perk );
	}
	return perk_array;
}
onPlayerRevived()
{
	self endon("disconnect");
	level endon("end_game");
	
	for(;;)
	{
		self waittill_any( "whos_who_self_revive","player_revived","fake_revive","do_revive_ended_normally", "al_t" );
		wait 1;
		if(is_true(self.hadPHD))
		{
			self setperk( "PHD_FLOPPER" ); //removes the staminup perk functionality
			self.hasPHD = true;
			self.hadPHD = undefined;
			self thread drawCustomPerkHUD("specialty_doubletap_zombies", 0, (1, 0.25, 1));
		}
		else
			return;
	}
}