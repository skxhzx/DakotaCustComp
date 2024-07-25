/*-------------------------------------------------------------------*/
/*                                                                   */
/*  UT155CL   Create item quantity records.                          */
/*  18 August, 1994                                                  */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    02/20/95  DAS                                                  */
/*      - Revised OPNQRYF to include the warehouse along with the    */
/*        item as join fields.                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 UT150CL:    PGM        PARM(&USERPARM)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(UT150CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(UT150)


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&JOBQ)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USERPARM)   TYPE(*CHAR) LEN(4)   VALUE(' ')

             MONMSG     MSGID(CPF0000)   EXEC(GOTO CMDLBL(GETOUT))
/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Don't get options, if being run from JOBQ. */

             RTVJOBA    TYPE(&TYPE)
             IF (&TYPE = '0') THEN(GOTO DOIT)

/*  Don't get options, if &USERPARM = *NO      */

             IF         COND(&USERPARM = '*NO ') THEN(GOTO +
                          CMDLBL(DOIT))

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&RETURN)

/*  See if user wants to proceed. */

             IF (&RETURN = '*EXIT' *OR &RETURN = '*CANCEL') THEN(DO)
               RETURN
               ENDDO


/* See if user wants to put report on jobq. */

             IF (&RETURN = '*JOBQ') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&USERPARM)) +
                          JOB(&SBMPGM)
             GOTO       CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 DOIT:

   /* Override UT155 file. */

             OVRDBF     FILE(UT155) TOFILE(PIRITEM) SHARE(*YES)


   /* Use OPNQRYF to select and order the records we need */
   /* Select records from item file that do not have      */
   /* corresponding records in item quantity file.        */

             OPNQRYF    FILE((PIRITEM) (ITEMQTY)) FORMAT(UT155) +
                          KEYFLD((PIRITEM/ITITEM)) +
                          JFLD((PIRITEM/ITWHSE ITEMQTY/IQWHSE) +
                          (PIRITEM/ITITEM ITEMQTY/IQITEM)) +
                          JDFTVAL(*ONLYDFT)


             CALL       PGM(UT155)

 GETOUT:
   /* Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
