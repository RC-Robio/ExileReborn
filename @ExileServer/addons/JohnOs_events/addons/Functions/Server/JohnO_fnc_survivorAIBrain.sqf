private ["_group","_unit","_buildingPos","_buildings","_buildingPositions","_randomWaypoint","_nearPlayers"];

_group = _this select 0;
_unit = (units _group) select 0;

_buildingPos = [];

_unit setVariable ["ExileReborn_survivor_hasWaypoint",-1];

// Function to remove all waypoints on the AI

JohnO_fnc_deleteAIWaypoints =
{
	private ["_group","_unit","_holder","_items","_item"];
	_group = _this select 0;
	_unit = (units _group) select 0;

	while {(count (waypoints _group)) > 0} do
	{
	    deleteWaypoint ((waypoints _group) select 0);
	    if !(alive _unit) exitWith {};
	};

	_nearHolders = position _unit nearObjects ["GroundWeaponHolder", 2];

    if (count _nearHolders > 0) then
    {
    	_holder = _nearHolders select 0;
    	_items = _holder call ExileClient_util_containerCargo_list;

    	_item = selectRandom _items;

    	_itemType = _item  call ExileClient_util_cargo_getType;

    	if ((_itemType isEqualTo 1) || (_itemType isEqualTo 4)) then
    	{	

	    	if ([_unit,_item] call ExileClient_util_playerCargo_canAdd) then
	    	{	
	    	
	    		_unit playActionNow "PutDown";
	    		_unit addItem _item;
	    	};	
	    };	
    };

	_unit setVariable ["ExileReborn_survivor_hasWaypoint",-1];
};

// If the survivor is not following a player, give him a random waypoint

while {true} do
{

	if (!(alive _unit) || (isNull _unit)) exitWith {};

	if ((_unit getVariable ["ExileReborn_survivor_switchHostile",-1] isEqualTo 1)) exitWith
	{
		_unit setVariable ["ExileReborn_survivor_switchHostile",2];
		_unit setVariable ["ExileReborn_survivor",false,true];

		_newGroup = createGroup east;
		[_unit] joinSilent _newGroup;

		[_newGroup,getPos _unit,500] call JohnO_fnc_taskPatrol;
		_unit enableAI "MOVE";

		deleteGroup _group;
	};

	_nearPlayers = getPos _unit nearEntities [['Exile_Unit_Player'],5]; 

	if ((count _nearPlayers > 0) && ((_unit getVariable ["ExileReborn_survivor_isFollowing",-1]) isEqualTo -1)) then
	{
		uiSleep 0.1;
		_unit disableAI "MOVE";
		_objectToLookAt = selectRandom _nearPlayers;

		_direction = (getDir _objectToLookAt) - 180;

		_unit lookAt _objectToLookAt;
		_unit doWatch _objectToLookAt;
		_unit setDir _direction;
	}
	else
	{
		_unit enableAI "MOVE";
		_unit doWatch objNull;
	};

	if ((_unit getVariable ["ExileReborn_survivor_isFollowing",-1]) isEqualTo -1) then
	{
		if ((_unit getVariable ["ExileReborn_survivor_hasWaypoint",-1]) isEqualTo -1) then
		{	
			_buildings = _unit nearObjects ["House", 300];
			{
				if !(_buildings isEqualTo []) then 
				{
					_buildingPositions = _x buildingPos -1;
					{
						_buildingPos pushBack _x;
					} forEach _buildingPositions;	
				};
			} forEach _buildings;

			_randomWaypoint = selectRandom _buildingPos;

			_wp = _group addWaypoint [_randomWaypoint,0];
			_wp setWaypointType "MOVE";
			_wp setWaypointBehaviour "AWARE";
			_wp setWaypointStatements ["true","[group this] spawn JohnO_fnc_deleteAIWaypoints"];

			_unit setVariable ["ExileReborn_survivor_hasWaypoint",1];
		};	
	}
	else
	{
		//_playerToFollow = _unit getVariable ["ExileReborn_survivor_isFollowing",-1];
		_playerObject = _unit getVariable ["ExileReborn_survivor_isFollowing",-1];

		_playerToFollow = objectFromNetId _playerObject;

		if ((isPlayer _playerToFollow) && !(isNull _playerToFollow)) then
		{

			if !(alive _playerToFollow) then
			{
				_unit setVariable ["ExileReborn_survivor_isFollowing",-1,true];
			};	

			if ((_unit getVariable ["ExileReborn_survivor_hasWaypoint",-1]) isEqualTo -1) then
			{

				_playerPos = position _playerToFollow;

				_wp = _group addWaypoint [_playerPos,10];
				_wp setWaypointType "MOVE";
				_wp setWaypointBehaviour "AWARE";
				_wp setWaypointStatements ["true","[group this] spawn JohnO_fnc_deleteAIWaypoints"];

				_unit setVariable ["ExileReborn_survivor_hasWaypoint",1];
			};	
		};	
	};

	uiSleep 1;	
};













