/*********************************************************************/
/*                                                                   */
/*  UPDPIR      Update PIR from update libraries.                    */
/*  01 March 1996                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: UPDPIR                               */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*  07/17/97  RH   4.02                                              */
/*  -  Add Parameters &ULIB &ULIBF library & file library to update  */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &ULIB        Library to update                                   */
/*  &ULIBF       File library to update                              */
/*  &SOURCE      Update source (Y,N)                                 */
/*  &OBJS        Update objects (Y,N)                                */
/*  &FILES       Update files (Y,N)                                  */
/*  &JOBQ        Put on jobq (Y,N)                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Load PIR Updates')

             PARM       KWD(ULIB) TYPE(*CHAR) LEN(10) +
                          DFT(PIR) PROMPT('Program library to update')

             PARM       KWD(ULIBF) TYPE(*CHAR) LEN(10) +
                          DFT(PIRF) +
                          PROMPT('File library to update')

             PARM       KWD(SOURCE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          VALUES(*YES *NO) MIN(1) PROMPT('Update +
                          source')

             PARM       KWD(OBJECTS) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          VALUES(*YES *NO) MIN(1) PROMPT('Update +
                          objects')

             PARM       KWD(FILES) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          VALUES(*YES *NO) MIN(1) PROMPT('Update +
                          files')

             PARM       KWD(JOBQ) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) MIN(0) +
                          PROMPT('Place on JOBQ')

