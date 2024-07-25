/*******************************************************************/
/*******************************************************************/
/*                                                                 */
/*   *                                                                   */
/*   *    03/10/06  MLB  CBI                                             */
/*   *      - Test program to run system api's that                      */
/*   *        will change the owner of the spool file created by the     */
/*   *        program. This change was created in an attempt to exceed   */
/*   *        the 99,999 spool file limit per job.                       */
/*   *      - User profile BFCPRINT must exist for this mod to work.     */
/*   *                                                                   */
/* FUNCTION:  ILLUSTRATES HOW TO GENERATE, CHANGE, AND RELEASE     */
/*            PROFILE HANDLES IN A CL PROGRAM.                     */
/*                                                                 */
/* LANGUAGE:  CL                                                   */
/*                                                                 */
/* APIS USED: QSYGETPH    - GET PROFILE HANDLE                     */
/*            QWTSETP     - SET PROFILE                            */
/*            QSYRLSPH    - RELEASE PROFILE HANDLE                 */
/*                                                                 */
/*******************************************************************/
/*******************************************************************/

             PGM        PARM(&USERID &PWD &PCMD &PLSET &PLFMT &PWHSE +
                          &PRTID &PCOMP &PTZON &PGEN &PSZON &PTRUK +
                          &PRTE &POPZDTA &PTRN# &PLBL# &PQTY &PWGT)

/* DECLARE THE CALLING PGM VARIABLES NEEDED BY THIS PROGRAM:            */
             DCL        VAR(&PCMD)   TYPE(*CHAR) LEN(8)
             DCL        VAR(&PLSET)  TYPE(*CHAR) LEN(6)
             DCL        VAR(&PLFMT)  TYPE(*CHAR) LEN(8)
             DCL        VAR(&PWHSE)  TYPE(*DEC)  LEN(3 0)
             DCL        VAR(&PRTID)  TYPE(*CHAR) LEN(5)
             DCL        VAR(&PCOMP)  TYPE(*CHAR) LEN(1)
             DCL        VAR(&PTZON)  TYPE(*CHAR) LEN(6)
             DCL        VAR(&PGEN)   TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&PSZON)  TYPE(*CHAR) LEN(6)
             DCL        VAR(&PTRUK)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&PRTE)   TYPE(*CHAR) LEN(5)
             DCL        VAR(&POPZDTA) TYPE(*CHAR) LEN(117)
             DCL        VAR(&PTRN#)  TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&PLBL#)  TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&PQTY)   TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&PWGT)   TYPE(*DEC)  LEN(7 2)

/* DECLARE THE VARIABLES NEEDED BY THIS PROGRAM:            */
             DCL        VAR(&USERID) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PWD) TYPE(*CHAR) LEN(10)
             DCL        VAR(&CURRUSER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&SECPWD) TYPE(*CHAR) LEN(10) VALUE(*NOPWD)
             DCL        VAR(&PRFHNDL1) TYPE(*CHAR) LEN(12)
             DCL        VAR(&PRFHNDL2) TYPE(*CHAR) LEN(12)

/* GENERATE PROFILE HANDLES FOR THE QSECOFR USER ID AND    */
/* FOR THE USER ID PASSED TO THIS PROGRAM:                 */

             RTVJOBA    USER(&CURRUSER)
             CALL       PGM(QSYGETPH) PARM(&CURRUSER &SECPWD &PRFHNDL1)
             CALL       PGM(QSYGETPH) PARM(&USERID &PWD &PRFHNDL2)

/* CHANGE THE USER FOR THIS JOB TO THE USER ID PASSED TO   */
/* THIS PROGRAM:                                           */

             CALL       PGM(QWTSETP) PARM(&PRFHNDL2)

/* THIS PROGRAM IS NOW RUNNING UNDER THE USER ID PASSED TO */
/* THIS PROGRAM.                                           */

/* Print belt printer labels                               */
             CALL       PGM(PFMT) PARM(&PCMD &PLSET &PLFMT &PWHSE +
                          &PRTID &PCOMP &PTZON &PGEN &PSZON &PTRUK +
                          &PRTE &POPZDTA &PTRN# &PLBL# &PQTY &PWGT)

/* NOW CHANGE THE USER ID FOR THIS JOB BACK TO THE CURRENT USER PROFILE */
/* USER ID:                                                */

/* NOW CHANGE THE USER ID FOR THIS JOB BACK TO THE QSECOFR */
/* USER ID:                                                */

             CALL       PGM(QWTSETP) PARM(&PRFHNDL1)

/*           RVKOBJAUT  OBJ(QWTSETP) OBJTYPE(*PGM) USER(&USERID) +
                          AUT(*USE)   */

/* THE PROFILE HANDLES GENERATED IN THIS PROGRAM CAN NOW   */
/* BE RELEASED:                                            */

             CALL       PGM(QSYRLSPH) PARM(&PRFHNDL1)
             CALL       PGM(QSYRLSPH) PARM(&PRFHNDL2)

ENDPGM


