% vtcons.hrl -- ANSI/VT100 style terminal handling (crude).
% Fred Barnes, University of Kent.


% NOTE: The correct way to do terminal output is using something like curses/ncurses.
% directly blasting VT escape sequences usually works, but isn't exactly clean.

-define (ANSI_ATTR_NORMAL, 0).
-define (ANSI_ATTR_BOLD, 1).
-define (ANSI_ATTR_UNDERLINE, 4).
-define (ANSI_ATTR_BLINK, 5).
-define (ANSI_ATTR_REVERSE, 7).

-define (ANSI_FG_BLACK, 30).
-define (ANSI_FG_RED, 31).
-define (ANSI_FG_GREEN, 32).
-define (ANSI_FG_YELLOW, 33).
-define (ANSI_FG_BLUE, 34).
-define (ANSI_FG_MAGENTA, 35).
-define (ANSI_FG_CYAN, 36).
-define (ANSI_FG_WHITE, 37).

-define (ANSI_BG_BLACK, 40).
-define (ANSI_BG_RED, 41).
-define (ANSI_BG_GREEN, 42).
-define (ANSI_BG_YELLOW, 43).
-define (ANSI_BG_BLUE, 44).
-define (ANSI_BG_MAGENTA, 45).
-define (ANSI_BG_CYAN, 46).
-define (ANSI_BG_WHITE, 47).


% documentation: call 'vtcons' with a tuple describing what to output.  See the
% various patterns below for acceptable commands.

vtcons ({cursor_xy, X, Y}) -> %{{{  move cursor to the specified position (screen starts at 1,1 in the top-left)
	io:format ("~c[~w;~wH", [27, Y, X]),
	true;
%}}}
vtcons ({cursor_up, N}) -> %{{{  move cursor up N lines
	io:format ("~c[~wA", [27, N]),
	true;
%}}}
vtcons ({cursor_down, N}) -> %{{{  move cursor down N lines
	io:format ("~c[~wB", [27, N]),
	true;
%}}}
vtcons ({cursor_left, N}) -> %{{{  move cursor left N columns
	io:format ("~c[~wD", [27, N]),
	true;
%}}}
vtcons ({cursor_right, N}) -> %{{{  move cursor right N columns
	io:format ("~c[~wC", [27, N]),
	true;
%}}}
vtcons ({erase_eol}) -> %{{{  erase from cursor to end-of-line
	io:format ("~c[0K", [27]),
	true;
%}}}
vtcons ({erase_line}) -> %{{{  erase whole line
	io:format ("~c[2K", [27]),
	true;
%}}}
vtcons ({erase_eos}) -> %{{{  erase from cursor to end-of-screen
	io:format ("~c[0J", [27]),
	true;
%}}}
vtcons ({erase_bos}) -> %{{{  erase from cursor to beginning-of-screen
	io:format ("~c[1J", [27]),
	true;
%}}}
vtcons ({erase_screen}) -> %{{{  erase whole screen
	io:format ("~c[2J", [27]),
	true;
%}}}
vtcons ({cursor_visible}) -> %{{{  show the cursor
	io:format ("~c[?25h", [27]),
	true;
%}}}
vtcons ({cursor_invisible}) -> %{{{  hide the cursor
	io:format ("~c[?25l", [27]),
	true;
%}}}
vtcons ({ansi, A}) -> %{{{  single ANSI attribute (e.g. ANSI_FG_RED or ANSI_ATTR_NORMAL)
	io:format ("~c[~wm", [27, A]),
	true;
%}}}
vtcons ({ansi, A, B}) -> %{{{  double ANSI attribute (e.g. ANSI_ATTR_BOLD, ANSI_FG_RED)
	io:format ("~c[~w;~wm", [27, A, B]),
	true;
%}}}
vtcons ({ansi, A, B, C}) -> %{{{  triple ANSI attribute (e.g. ANSI_ATTR_BOLD, ANSI_FG_RED, ANSI_BG_YELLOW)
	io:format ("~c[~w;~w;~wm", [27, A, B, C]),
	true;
%}}}
vtcons ({string, S}) -> %{{{  writes a string to the screen (trivial)
	io:format ("~s", [S]),
	true;
%}}}
vtcons ({num, N}) -> %{{{  writes a number (in base 10) to the screen (trivial)
	io:format ("~w", [N]),
	true;
%}}}


vtcons ([]) -> true; %{{{  handling for lists of tuples (processed in order)
vtcons ([X | Xs]) ->
	vtcons (X) andalso vtcons (Xs).
%}}}


