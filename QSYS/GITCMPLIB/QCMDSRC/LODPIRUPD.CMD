/*********************************************************************/
/*                                                                   */
/*  LODPIRUPD   Load PIR updates.                                    */
/*  01 March 1996                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Command Processing Program: LODPIRUPD                            */
/*  Validity Checking Program:  None                                 */
/*  Revisions:                                                       */
/*  07/17/97  RH   4.02                                              */
/*  -  Add Parameters &ULIB &ULIBF library & file library to update  */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Parameters                                                       */
/*  &TYPE        Load type                                           */
/*  &ULIB        Library to update                                   */
/*  &ULIBF       File library to update                              */
/*  &DEVICE      Tape device                                         */
/*  &JOBQ        Put on jobq (Y,N)                                   */
/*                                                                   */
/*********************************************************************/

             CMD        PROMPT('Load PIR Updates')

             PARM       KWD(TYPE) TYPE(*CHAR) LEN(9) RSTD(*YES) +
                          VALUES(*DIRECT *INDIRECT) MIN(1) +
                          PROMPT('Load type')

             PARM       KWD(ULIB) TYPE(*CHAR) LEN(10) +
                          DFT(PIR) PROMPT('Program library to update')

             PARM       KWD(ULIBF) TYPE(*CHAR) LEN(10) +
                          DFT(PIRF) +
                          PROMPT('File library to update')

             PARM       KWD(DEVICE) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Device')

             PARM       KWD(JOBQ) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) MIN(0) +
                          PROMPT('Place on JOBQ')

