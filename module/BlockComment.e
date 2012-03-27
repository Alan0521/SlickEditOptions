#include "slick.sh"

//
// macro to automate block commenting or uncommenting large sections of source code
//
// to use, simply select the desired lines, and execute the BlockComment macro.
// The highlighted lines will be block-commented out, using the appropriate comment
// characters for the source file type being edited.  If the lines are already
// block-commented out, they will be uncommented.
// Works on current line if nothing selected.
//
// The macro is clever enough to respond appropriately for a variety of different
// source types, including .cpp, .h, .e, .l, .java, .pl, .pm, .mak, .mk, and .f
//
// original author:  Elliott W. Jackson
//                   HS2 - 060801:  relaxed selection requirements
//                                  extended extension checking
//                                  use status line for telling a problem instead of pop-up
//


// worker subroutine called by main BlockComment routine
static void ProcessBlockComment(_str commentstring)
{
    int commentlen;
    commentlen = length(commentstring);

    // if nothing selected select curr. line or force line selection
    if ( ! select_active () )
       select_line();
    else
       _select_type('', '', 'LINE');

    // save insert mode, and set mode to insert
    int insertstate;
    insertstate = _insert_state();
    _insert_state(1);
    //messageNwait("Insert state is "insertstate);

    // save current position
    push_bookmark();

    // goto the block beginning
    begin_select();
    begin_line();

    // are we adding or removing comments?
    _str buff;
    buff = get_text(commentlen);

    int removeflag;
    if (buff == commentstring)
        removeflag = 1;
    else
        removeflag = 0;

    // comment out or uncomment all blocked lines
    int numlines;
    int count;

    numlines = count_lines_in_selection();
    for (count = 0; count < numlines; count++)
    {
        begin_line();

        if (removeflag)
        {
            int i;
            i = commentlen;
            while (i--)
            {
                delete_char();
            }
        }
        else
            _insert_text(commentstring);

        cursor_down();
    }


    // restore original cursor pos
    pop_bookmark();

    // restore original insert mode
    _insert_state(insertstate);

    // turn off the selection
    deselect();

    // final message
    if (removeflag)
        message(numlines" lines uncommented");
    else
        message(numlines" lines commented");
}



_command BlockComment()
{
    // get extension
    _str ext;
    ext = lowcase(get_extension(p_buf_name));

    // handle .cpp files, .h files, vslick .e/.sh files, lex .l files
    if ( pos (ext, '(cpp)|(h)|(e)|(sh)|(l)|(java)', 1, 'R' ) )
    {
        ProcessBlockComment("//");
    }

    // handle perl files and make files
    else if ( pos (ext, '(pl)|(pm)|(mk)|(mak)', 1, 'R' ) )
    {
        ProcessBlockComment("#");
    }

    // handle batch script files
    else if ( pos (ext, '(bat)|(cmd)', 1, 'R' ) )
    {
       ProcessBlockComment("REM");
    }

    // handle ini-formatted files
    else if ( pos (ext, '(ini)|(inf)|(inx)', 1, 'R' ) )
    {
       ProcessBlockComment(";");
    }

    // handle fortran files
    else if ( (ext == "f") )
    {
        ProcessBlockComment("C");
    }

    // huh?
    else
    {
        // _message_box("I don't know how to BlockComment this file extension", "Error", MB_ICONEXCLAMATION);
        // just tell on status line and 'signal' the error
        message ("I don't know how to BlockComment this file extension !");
        _beep();
    }
}



