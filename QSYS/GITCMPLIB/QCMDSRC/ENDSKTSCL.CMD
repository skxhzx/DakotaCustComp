/*********************************************************************/
/*                                                                   */
/*  ENDSKTSCL   Run BFCSKTSCL server                                 */
/*  23 January 2014                                                  */
/*  Kenneth Elder                                                    */
/*                                                                   */
/*  Command Processing Program: ENDSKTSCL     QRPGSRC                */
/*      AND CL ENDSKTSCLC                                            */
/*  Validity Checking Program:  CHKSCLPOR                            */
/*                                                                   */
/*  Revisions:                                                       */
/*                                                                   */
/*    01/23/14  KDE  6.20                                            */
/*      - Created.                                                   */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &PORT        Port number Toldeo Scale client uses                */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('End BFCSKTSCL Scale client')

             PARM       KWD(PORT) TYPE(*CHAR) LEN(5) DFT(6001) +
                          CHOICE(*PGM) CHOICEPGM(DSPSCLPOR) +
                          PROMPT('Single IP Port or *ALL')

