-module(erlfetch).
-include("vtcons.hrl").
-compile([export_all]).

-define(windows10logo, [ "                         ....::::",
						 "                 ....::::::::::::",
  						 "        ....:::: ::::::::::::::::",
  						 "....:::::::::::: ::::::::::::::::",
 						 ":::::::::::::::: ::::::::::::::::",
						 ":::::::::::::::: ::::::::::::::::",
						 ":::::::::::::::: ::::::::::::::::",
 						 ":::::::::::::::: ::::::::::::::::",
 						 "................ ................",
 						 ":::::::::::::::: ::::::::::::::::", 
 						 ":::::::::::::::: ::::::::::::::::",
 						 ":::::::::::::::: ::::::::::::::::",
 						 ":::::::::::::::: ::::::::::::::::",
 						 "'''':::::::::::: ::::::::::::::::",
 						 "        '''':::: ::::::::::::::::",
 						 "                 ''''::::::::::::",
 						 "                         ''''::::" ]).
main() ->
    drawSprite(?windows10logo, 0),
	drawInfo().

drawInfo() ->
	Output = [ "User:         " ++ user@host(),
		       "OS:           " ++ os(),
               "Up Time:      " ++ uptime(),
               "Kernel:       " ++ kernel(),
               "Shell:        " ++ shell(),
               "Term:         " ++ term(),
               %"WM:           " ++ windowmanager(),%
               "VisualStyle:  " ++ visualstyle() ],
	vtcons({cursor_up, length(?windows10logo)-length(Output) div 2}),
	drawSprite(Output, 38),
	vtcons({cursor_xy, 1, length(?windows10logo)+5}).
	

user@host() ->
    os:getenv("user") ++ "@" ++ os:getenv("hostname").

os() ->
    formatRaw(os:cmd("wmic os get Caption"), "Caption").

uptime() ->
    RawReturn = formatRaw(os:cmd("wmic os get lastbootuptime"), "LastBootUpTime"),
    Year  = list_to_integer(string:substr(RawReturn, 1, 4)),
    Month = list_to_integer(string:substr(RawReturn, 5, 2)),
    Day   = list_to_integer(string:substr(RawReturn, 7, 2)),
    Hour  = list_to_integer(string:substr(RawReturn, 9, 2)),
    Min   = list_to_integer(string:substr(RawReturn, 11, 2)),
    Sec   = list_to_integer(string:substr(RawReturn, 13, 2)),
    LastBootTime  = {{Year, Month, Day}, {Hour, Min, Sec}},
    CurrentTime   = calendar:local_time(),
    UpTime = calendar:time_difference(LastBootTime, CurrentTime),
    {UpDays, {UpHours, UpMins, UpSecs}} = UpTime,
    ReturnString = integer_to_list(UpDays) ++ " Days, " ++
		integer_to_list(UpHours) ++ " Hours, " ++
		integer_to_list(UpMins) ++ " Minutes and " ++
		integer_to_list(UpSecs) ++ " Seconds".
	

kernel() ->
    formatRaw(os:cmd("uname -sr")).

shell() ->
    binary_to_list(lists:last(re:split(os:getenv("Shell"), "/"))).

term() ->
    os:getenv("Term").

visualstyle() ->
    VSDir        = "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ThemeManager",
    RegList      = re:split(formatRaw(os:cmd("reg query " ++ VSDir)), "\\\\|\s+"),
    StrippedList = lists:map(fun(X) -> formatRaw(X) end, RegList),
    [VS|_Rest]   = lists:filter(fun(X) -> isFileType(".msstyles", X) end, StrippedList),
    re:replace(VS, ".msstyles", "", [global, {return, list}]).  

windowmanager() ->
	case isRunning("blackbox.exe") of
		true ->
			case isRunning("ShellExperienceHost.exe") of
				true  -> ReturnVal = "Explorer";
                false -> ReturnVal = "BlackBox"
            end
	end,
    ReturnVal.

bbleanskin() ->
	case isRunning("bbLeanSkinRun64.exe") of
		true ->
			"Enabled (64bit)";
        false -> ok
	end,
    case isRunning("bbLeanSkinRun32.exe") of
        true ->
            "Enabled (32bit)";
        false ->
            "Disabled"
    end.

isFileType(FileType, String) ->
    OriginalLength = length(String),
    Check = re:replace(String, FileType, ""),
    if 
        length(Check) < OriginalLength ->  true;
        true -> false
    end.

formatRaw(String, SubString) ->
    SansSubString = re:replace(String, SubString, ""),
    formatRaw(SansSubString).

formatRaw(String) ->
    re:replace(
        re:replace(String, "|\\s+$", "", [global, {return, list}]),
        "^\\s+", "", [global, {return, list}]).

isRunning(Process) ->
    Result = formatRaw(os:cmd("tasklist /fi \"imagename eq " ++ Process ++"\"")),
	Check  = re:replace(Result, "INFO: No tasks are running which match the specified criteria.", ""),
	CheckSize = length(Check),
	case CheckSize of
		1 -> false;
		_ -> true
	end.

drawSprite(Sprite, XCoord) ->
    drawSprite(Sprite, XCoord, length(Sprite)).
drawSprite(Sprite, XCoord, 0) ->
    done;
drawSprite(Sprite, XCoord, Lines) ->
	lists:map(fun(X) -> 
		vtcons({cursor_right, XCoord}),
		io:format(X ++ "\n") end,
		Sprite).
