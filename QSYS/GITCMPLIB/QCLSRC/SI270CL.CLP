/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SI270CL   FTP StuffIt import 3                                   */
/*  01 June 2005                                                     */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    06/01/05  MLB  5.00                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    06/03/08  MLB  5.20                                            */
/*      - Enh: Added client custom code support to pgm.              */
/*    10/11/16  MLB  7.00                                            */
/*      - Fix: Corrected SBMJOB cmd to add missing &CMD parm.        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Fox River                               */
/*                                                                   */
/*  06/03/08  MLB  FRF                                               */
/*    - Enh: Revised program to clear VSLOT file, delete virtual     */
/*      slots from SLOT file and then initialize all slot fields     */
/*      for new StuffIt processing.                                  */
/*  07/01/08  MLB  FRFa                                              */
/*    - Enh: Revised previous mod, FRF to only clear SLOT, VSLOT     */
/*      files when &cmd = *FULL. Adding new cmd, *FRFROC that will   */
/*      process external storage locations and put items into new    */
/*      slots. A call to HQ240CL is being added to do the actual     */
/*      processing of the qty into the slot so that an audit trail   */
/*      will be produced.                                            */
/*  09/26/08  MLB  FRFb                                              */
/*    - Enh: Revised previous mod, FRFa to only clear SLOT, VSLOT    */
/*      files when &cmd = *FULL or *FRFPINV.                         */
/*  10/25/09  MLB  FRFc                                              */
/*    - Enh: Revised call to HQ240CL to pass &CMD parm to program,   */
/*      HQ240CL. &CMD parm needed for new support being added to     */
/*      HQ240CL pgm.                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Dairyland                               */
/*                                                                   */
/*  04/14/10  MLB  DRY                                               */
/*    - Enh: Revised program to remove import member from file       */
/*      upon successful completion.                                  */
/*  07/09/10  MLB  TEMP MOD                                          */
/*    - Enh: Revised program to NOT REMOVE IMPORT MBR.               */
/*  09/27/11  MLB  DRYa                                              */
/*    - Removed Dairyland Temp mod.                                  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Nicholas & Co.                          */
/*                                                                   */
/*  09/27/11  MLB  NCH                                               */
/*    - Enh: Revised program to remove import member from file       */
/*      upon successful completion.                                  */
/*    - Added NCH to DRY mod.                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Glazier Foods                           */
/*                                                                   */
/*  06/09/10  MLB  GLZ                                               */
/*    - Enh: Revised program to clear pick slot fields and load      */
/*      new items, qty into slots once each week.                    */
/*  06/28/10  MLB  GLZa                                              */
/*    - Enh: Revised program to clear all slots , fields and load    */
/*      new items, qty into slots once each week.                    */
/*  06/02/11  MLB  GLZb                                              */
/*    - Enh: Disabled GLZ, GLZa. Needed for add new DRY dept slots.  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Avalon Foodservice                      */
/*                                                                   */
/*  09/27/11  MLB  AVL                                               */
/*    - Enh: Revised program to remove import member from file       */
/*      upon successful completion.                                  */
/*    - Added AVL to DRY mod.                                        */
/*  07/09/10  MLB  TEMP MOD                                          */
/*    - Enh: Revised program to NOT REMOVE IMPORT MBR.               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Agar Supply                             */
/*                                                                   */
/*  08/03/12  MLB  ASC                                               */
/*    - Enh: Revised program to remove import member from file       */
/*      upon successful completion.                                  */
/*    - Added ASC to DRY mod.                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Reinhart Foodservice                    */
/*                                                                   */
/*  06/01/13  MLB  RFS                                               */
/*    - Enh: Revised program to remove import member from file       */
/*      upon successful completion.                                  */
/*    - Added RFS to DRY mod.                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &CMD   -  *FULL    - Clear all slot fields. Delete all virtual */
/*                         slots.                                    */
/*           -  *PARTIAL - No slot fields are cleared. Only slots    */
/*                         sent in file are processed and updated.   */
/* (FRFbA)   -  *FRFPINV - Clear slots after phy. inventory. Delete  */
/*                         all virtual slots, initialize base slots. */
/*           -  *FRFROC  - 01ROC slots are processed. No clearing.   */
/*                         HQ240CL is called to do adjustments.      */
/*    &MBR   -  Member to create. Must start with alpha character.   */
/*    &RUN   -  *INTER  Run interactively                            */
/*              *JOBQ   Run on Jobq                                  */
/*    &OUTQ  -  Printer output queue (Default is *JOB)               */
/*    &FORM  -  Printer form (Default is *STD)                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SI270CL:    PGM        PARM(&CMD &MBR &RUN &OUTQ &FORM)

/*-------------------------------------------------------------------*/
/*  Customer ID's                                           (510aA)  */
/*-------------------------------------------------------------------*/
             DCL        VAR(&Agar)        TYPE(*CHAR) LEN(10) +
                          VALUE('AGAR')                  /* (ASC A) */
             DCL        VAR(&Foxriver)    TYPE(*CHAR) LEN(10) +
                          VALUE('FRF')                   /* (FRF A) */
             DCL        VAR(&Glazier)     TYPE(*CHAR) LEN(10) +
                          VALUE('GLAZIER')               /* (GLZ A) */
             DCL        VAR(&Dairyland)    TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')             /* (DRY A) */
             DCL        VAR(&Avalon   )    TYPE(*CHAR) LEN(10) +
                          VALUE('AVALON')                /* (AVL A) */
             DCL        VAR(&Nicholas)     TYPE(*CHAR) LEN(10) +
                          VALUE('NICHOLAS')              /* (NCH A) */
             DCL        VAR(&RFS)        TYPE(*CHAR) LEN(10) +
                          VALUE('RFS')                   /* (RFS A) */

             DCL        VAR(&CLIENT) TYPE(*CHAR) LEN(10) +
                          VALUE(' ')                     /* (520 A) */
             DCL        VAR(&CLIENTLOC) TYPE(*CHAR) LEN(10) +
                          VALUE(' ')                     /* (520 A) */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program. */

             DCL        VAR(&SBMPGM) TYPE(*CHAR) LEN(10) +
                          VALUE(SI270CL)

  /* Option program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(SI270)

  /* Report program and printer file names. */

             DCL        VAR(&RPTPGM) TYPE(*CHAR) LEN(8) +
                          VALUE(SI275)
             DCL        VAR(&PRTF) TYPE(*CHAR) LEN(10) +
                          VALUE(SI275PR)

  /* Informational messages */

             DCL        VAR(&CANCELMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('FTP StuffIt Import 3')
             DCL        VAR(&WORKINGMSG) TYPE(*CHAR) LEN(60) +
                          VALUE('Importing FTP StuffIt 3')

  /* Messag queues */

             DCL        VAR(&FTPMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPSTUF')
             DCL        VAR(&FTPERRMSGQ) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPSTUFERR')

  /* Import files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('IMPFSTUF3')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CMD)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&EXIST)      TYPE(*LGL)
             DCL        VAR(&FINISHED)   TYPE(*LGL)
             DCL        VAR(&FORM)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBR2)       TYPE(*CHAR) LEN(10)         /* FRFaA */
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&OUTQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&QUOTE)      TYPE(*CHAR) LEN(1) VALUE('"') /* FRF */
             DCL        VAR(&RUN)        TYPE(*CHAR) LEN(8)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&STMT)       TYPE(*CHAR) LEN(1280)    /* (FRF A) */
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&USER)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&WHSE)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&WHSE30)     TYPE(*DEC)   LEN(3 0)    /* (FRF A) */
             DCL        VAR(&WHSEA)      TYPE(*CHAR)  LEN(3)      /* (FRF A) */

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(GETOUT))

/*    * Get client id.                                                (520 A) */

             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)    /* (520 A) */

             CHGVAR     VAR(&ERRCNT) VALUE(0)
             CHGVAR     VAR(&EXIST) VALUE('0')
             CHGVAR     VAR(&FINISHED) VALUE('0')

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get job information */

             RTVJOBA    JOB(&JOB) USER(&USER) TYPE(&TYPE)

/* See if user wants to run from Jobq. */

             IF (&RUN = '*JOBQ') THEN(DO)
               CHGVAR VAR(&RETURN) VALUE('*JOBQ')
               GOTO CMDLBL(SKIP1)
             ENDDO

/* Don't get options if being run from JOBQ. */

             IF ((&TYPE = '0') *OR (&MBR *NE ' ')) THEN(GOTO REPORT)

/*  Get report options. */

             CALL       PGM(&OPTPGM) PARM(&RETURN &MBR &OUTQ &FORM)

/*  See if user wants to proceed. */

             IF         COND((&RETURN *EQ '*CANCEL') *OR (&RETURN +
                          *EQ '*EXIT')) THEN(DO)
               SNDPGMMSG  MSGID(PIR9801) MSGF(PIRMSGF) +
                          MSGDTA(&CANCELMSG) MSGTYPE(*INFO)
               RETURN
             ENDDO

 SKIP1:

/*  Make sure members exist                                          */

             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             CHGVAR     VAR(&EXIST) VALUE('1')

/*  See if user wants to put report on JOBQ. */

             IF (&RETURN *EQ '*JOBQ') THEN(DO)
             SBMJOB     CMD(CALL PGM(&SBMPGM) PARM(&CMD &MBR '*JOBQ2' +
                          &OUTQ &FORM)) JOB(&SBMPGM)              /* (700 M) */
               RMVMSG     CLEAR(*ALL)
               CHGVAR  VAR(&FINISHED) VALUE('1')
               GOTO    CMDLBL(GETOUT)
             ENDDO

/*  Otherwise, run program. */

 REPORT:

/* Clear Slot and VSLOT files in preparation for new Slot StuffIt    (FRF A) */

             IF         COND(&CLIENT = &FOXRIVER) THEN(DO)        /* (FRF A) */
/*           IF         COND(&Cmd = '*FULL')      THEN(DO)        /* (FRFbD) */
             IF         COND(&CMD = '*FULL' *OR &CMD = '*FRFPINV') +
                          THEN(DO)                                /* (FRFbM) */

               MSGBFC     MESSAGE('Dakota Slot files being initialized.')
               CHGVAR     VAR(&WHSE30) VALUE(001)                 /* (FRF A) */
               CHGVAR     VAR(&WHSEA) VALUE(&WHSE30)              /* (FRF A) */

               CHGVAR     VAR(&STMT) VALUE('delete from VSLOT +
                            where vswhse =' *cat &whsea)
               MCSQL      STM(&STMT)

               CHGVAR     VAR(&STMT) VALUE('delete from SLOT +
                            where slwhse =' *cat &whsea +
                            *bcat 'and slrsrv=''V'' ')
               MCSQL      STM(&STMT)

               CHGVAR     VAR(&STMT) VALUE('update SLOT set slstat=''V +
                            '', slitem='' '', slsdte=0,slstim=0, +
                            slentd=0, +
                            slstk1=0,slstk2=0,slstk3=0,slpck1=0,slpck2+
                            =0,sltfr1=0,sltfr2=0,slrcv1=0, +
                            slrcv2=0,slexpd=0  where slwhse =' *CAT +
                            &WHSEA *BCAT 'and slstat <> ''V'' ')
               MCSQL      STM(&STMT)

             ENDDO                                                /* (FRFaA) */
             IF         COND(&Cmd = '*FRFROC')    THEN(DO)        /* (FRFaA) */

             CHGVAR     VAR(&MBR2) VALUE('P' *cat %sst(&mbr 1 9)) /* (FRFaA) */
             ADDPFM     FILE(IMPFPCKQ) MBR(&MBR2)                 /* (FRFaA) */
             MONMSG     MSGID(CPF7306) EXEC(DO)                   /* (FRFaA) */
               CLRPFM     FILE(IMPFPCKQ) MBR(&MBR2)               /* (FRFaA) */
             ENDDO                                                /* (FRFaA) */

             ENDDO                                                /* (FRFaA) */

             ENDDO                                                /* (FRF A) */

             IF         COND(&CLIENT = &Glazier) THEN(DO)         /* (GLZ A) */
             GOTO       CMDLBL(SKIPGLZ)                           /* (GLZbA) */

/* Clear pick slot field info and load new slot info.                (GLZ A) */

               MSGBFC     MESSAGE('Dakota Slot files being initialized.')
               CHGVAR     VAR(&WHSE30) VALUE(001)                 /* (GLZ A) */
               CHGVAR     VAR(&WHSEA) VALUE(&WHSE30)              /* (GLZ A) */

/*             CHGVAR     VAR(&STMT) VALUE('update SLOT set slstat=''V +
                            '', slitem='' '', slsdte=0,slstim=0, +
                            slentd=0, +
                            slstk1=0,slstk2=0,slstk3=0,slpck1=0,slpck2+
                            =0,sltfr1=0,sltfr2=0,slrcv1=0, +
                            slrcv2=0,slexpd=0  where slwhse =' *CAT +
                            &WHSEA *BCAT 'and slpick = ''Y'' ')   /* (GLZaD) */
               CHGVAR     VAR(&STMT) VALUE('update SLOT set slstat=''V +
                            '', slitem='' '', slsdte=0,slstim=0, +
                            slentd=0, +
                            slstk1=0,slstk2=0,slstk3=0,slpck1=0,slpck2+
                            =0,sltfr1=0,sltfr2=0,slrcv1=0, +
                            slrcv2=0,slexpd=0  where slwhse =' *CAT +
                            &WHSEA)                               /* (GLZaM) */
               MCSQL      STM(&STMT)                              /* (GLZ A) */

/*             Set all virtual pick slots to Zero status.            (GLZ A) */
             CHGVAR     VAR(&STMT) VALUE('update SLOT set slstat=''Z +
                          ''  where slwhse =' *CAT &WHSEA *BCAT +
                          'and slpick = ''Y'' and slrsrv = ''V'' ') +
                                                                  /* (GLZ A) */
               MCSQL      STM(&STMT)                              /* (GLZ A) */
/*             Remove all virtual pick slots at Zero status.         (GLZ A) */
               CALL AUTOVFYCL PARM('001')                         /* (GLZ A) */

               CHGVAR     VAR(&STMT) VALUE('delete from VSLOT +
                            where vswhse =' *cat &whsea)          /* (GLZaA) */
               MCSQL      STM(&STMT)                              /* (GLZaA) */

               CHGVAR     VAR(&STMT) VALUE('delete from SLOT +
                            where slwhse =' *cat &whsea +
                            *bcat 'and slrsrv=''V'' ')            /* (GLZaA) */
               MCSQL      STM(&STMT)                              /* (GLZaA) */

               CHGVAR     VAR(&STMT) VALUE('update label set lbstat=''C '' +
                            where lbwhse =' *cat &whsea +
                            *bcat 'and lbstat <> ''C '' ')        /* (GLZaA) */
               MCSQL      STM(&STMT)                              /* (GLZaA) */

               CHGVAR     VAR(&STMT) VALUE('update pirtran set +
                            ptstat=''4'',ptcdte=ptgdte where   ptwhse +
                            =' *CAT &WHSEA *BCAT 'and ptstat <>''4''  +
                            ')                                    /* (GLZaA) */
               MCSQL      STM(&STMT)                              /* (GLZaA) */

skipglz:                                                          /* (GLZbA) */
             ENDDO                                                /* (GLZ A) */

/*  Make sure members exist                                          */

             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             CHGVAR     VAR(&EXIST) VALUE('1')

/* Make sure &DEV and &FORM are not blank */

               IF (&OUTQ = ' ') +
                 THEN(CHGVAR VAR(&OUTQ) VALUE('*JOB'))
               IF (&FORM = ' ') +
                 THEN(CHGVAR VAR(&FORM) VALUE('*STD'))

/* Clear any existing messages and display working message. */

             RMVMSG     CLEAR(*ALL)
             MSGBFC     MESSAGE(&WORKINGMSG)

/* Override printer file */

             OVRPRTF    FILE(&PRTF) OUTQ(&OUTQ) FORMTYPE(&FORM)

/* Override import files to correct member */

             OVRDBF     FILE(&FILE) TOFILE(*FILE) MBR(&MBR)
             IF         COND(&cmd  = '*FRFROC')    THEN(DO)       /* (FRFaA) */
               ovrdbf     FILE(IMPFPCKQ) MBR(&MBR2)               /* (FRFaA) */
             ENDDO                                                /* (FRFaA) */

/* Clear Slots */

             IF         COND(&CMD = '*FULL') THEN(DO)
               CALL       PGM(SI274)
             ENDDO

/* Import Slots */

/*           CALL       PGM(&RPTPGM)                              /* (FRFaD) */
             CALL       PGM(&RPTPGM) PARM(&CMD)                   /* (FRFaD) */

             CHGVAR     VAR(&FINISHED) VALUE('1')

/*  Clean up before leaving */

             DLTOVR     FILE(*ALL)

             IF         COND(&cmd  = '*FRFROC')    THEN(DO)       /* (FRFaA) */
/*             Process adjustments for 01ROC slots.                  (FRFaA) */
/*             CALL HQ240CL PARM(&MBR2 &RUN &OUTQ &FORM)          /* (FRFcD) */
               CALL HQ240CL PARM(&CMD &MBR2 &RUN &OUTQ &FORM)     /* (FRFcM) */
             ENDDO                                                /* (FRFaA) */

       /*    RMVM       FILE(&FILE) MBR(&MBR)   */
             IF         COND(&CLIENT = &DAIRYLAND +
                         *OR &CLIENT = &AVALON +
                         *OR &CLIENT = &AGAR +
                         *OR &CLIENT = &RFS +
                         *or &CLIENT = &NICHOLAS)  THEN(DO)       /* (RFS M) */
               RMVM       FILE(&FILE) MBR(&MBR)                   /* (DRY A) */
               MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                           CPF3273 CPF7301 CPF7310)               /* (DRY A) */
             ENDDO                                                /* (DRY A) */
             RMVMSG     CLEAR(*ALL)

/*  Send 'Successful message */

             IF COND(&FINISHED = '1') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import successful for' *BCAT &MBR +
                          *TCAT '/' *CAT &RUN +
                          *TCAT '/' *CAT &JOB *TCAT '/' *CAT &USER) +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)
             ENDDO

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

             IF COND(&FINISHED = '0') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          message(s):' *BCAT &MBR *TCAT '/' *CAT +
                          &RUN *TCAT '/' *CAT +
                          &JOB *TCAT '/' *CAT &USER) +
                          TOMSGQ(&FTPMSGQ) MSGTYPE(*INFO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Import FAILED, see following +
                          message(s):' *BCAT &MBR *TCAT '/' *CAT +
                          &RUN *TCAT '/' *CAT +
                          &JOB *TCAT '/' *CAT &USER) +
                          TOMSGQ(&FTPERRMSGQ) MSGTYPE(*INFO)
             ENDDO

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

             IF COND(&TYPE = '1') THEN(DO)
               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) MSGTYPE(*COMP)
             ENDDO

               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                     MSGDTA(&MSGDTA) TOMSGQ(&FTPMSGQ) MSGTYPE(*COMP)

             IF COND(&FINISHED = '0') THEN(DO)
               SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOMSGQ(&FTPERRMSGQ) +
                          MSGTYPE(*COMP)
             ENDDO

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 BOTTOM:

               RCLRSC     LVL(*CALLER)

/*  Send '*Escape' message to caller */

             IF COND(&FINISHED = '0') THEN(DO)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                          MSGDTA('Error Occured Processing Member' +
                          *BCAT &MBR) MSGTYPE(*ESCAPE)
             ENDDO

             ENDPGM
