/*********************************************************************/
/*                                                                   */
/*  INSBLKLNE   Insert Blank Line in flatfile                        */
/*  21 August 2019                                                   */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Command Processing Program: INSBLKLNE                            */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*********************************************************************/
/*  Revisions:                                                       */
/*  08/21/19  KDE  7.30                                              */
/*    - Created.                                                     */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Insert Blank Line in flatfile')

             PARM       KWD(PLIB) TYPE(*CHAR) LEN(10) PROMPT('File Library')
             PARM       KWD(PFILE) TYPE(*CHAR) LEN(10) PROMPT('Flatfile')
             PARM       KWD(PLINE) TYPE(*dec) LEN(5 0) +
                          PROMPT('Insert after this relative rcd')
