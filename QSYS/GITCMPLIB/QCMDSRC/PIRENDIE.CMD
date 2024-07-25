/*********************************************************************/
/*                                                                   */
/*  PIRENDIE    End import/export servers                            */
/*  13 August 2008                                                   */
/*  Dave Sommerville                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*  Command Processing Program: PIRENDIE                             */
/*  Validity Checking Program:  None                                 */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    08/13/08  MLB  5.20                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &TYPE        I,E,B                                               */
/*  &HOW2END     1=Normal, 2=Abort                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('End Import/Export Servers')

             PARM       KWD(TYPE) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(B) VALUES(I E B) CHOICE('I=Import, +
                          E=Export, B=Both') PROMPT('Server type to +
                          end')

             PARM       KWD(HOW2END) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(1) VALUES(1 2) MIN(0) +
                          CHOICE('1=Normal, 2=Abort') PROMPT('How +
                          to end')

