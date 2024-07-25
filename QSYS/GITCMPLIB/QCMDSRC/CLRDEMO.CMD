/*********************************************************************/
/*                                                                   */
/*  CLRDEMO     Clear files in library BFCDEMO                       */
/*  28 September 2010                                                */
/*  Roxanne Harrsion                                                 */
/*                                                                   */
/*  Command Processing Program: CPYDEMO                              */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*    &CMD      Not entered - Set to *CLEAR                          */
/*    &CODE     Code to append to BFCDEMO                            */
/*    &LIBRARY  Not entered - Set to ' '                             */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Clear All Files in BFCDEMO')

             PARM       KWD(CMD) TYPE(*CHAR) LEN(9) CONSTANT(*CLEAR)

             PARM       KWD(CODE) TYPE(*CHAR) LEN(2) RTNVAL(*NO) +
                          RSTD(*NO) MIN(1) PROMPT('BFCDEMO library +
                          to clear')

             PARM       KWD(LIBRARY) TYPE(*CHAR) LEN(10) CONSTANT(' +
                          ')


