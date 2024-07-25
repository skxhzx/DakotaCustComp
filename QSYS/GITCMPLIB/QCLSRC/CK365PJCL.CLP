/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CK365PJCL  Submit Ship Check List with Blanks - Packers          */
/*  23 July, 2007                                                    */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*  Revision                                                         */
/*    10/08/07  MLB  PCKa                                            */
/*      - Created pgm to submit CK365PCL to batch instead of         */
/*        calling direct from socket program.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CK365PJCL:    PGM        PARM(&PWHSE &PRTID &PDEV &PFORM &PTRN#)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&PITEM)      TYPE(*CHAR) LEN(15)
             DCL        VAR(&PPGM)       TYPE(*CHAR) LEN(10) VALUE(CK394CL)
             DCL        VAR(&PPLID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PRTID)      TYPE(*CHAR) LEN(5)
             DCL        VAR(&PTRN#)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&QRYSLT)     TYPE(*CHAR) LEN(2000)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"')
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)
             DCL        VAR(&PDEV)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&PFORM)      TYPE(*CHAR) LEN(10)
             DCL        VAR(&PRTF1) TYPE(*CHAR) LEN(10) VALUE(CK365PPR)


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

   /* Submit CK365PCL to batch.         */

             SBMJOB     CMD(CALL PGM(CK365PCL) PARM(&PWHSE &PRTID +
                          &PDEV &PFORM &PTRN#)) JOB(CK365PCL) +
                          JOBQ(QBATCH)

             ENDPGM
