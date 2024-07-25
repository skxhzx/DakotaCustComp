/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TSTSAVLIB   Save BFC libraries to tape using save-while-active   */
/*  11 November 2004                                                 */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    11/11/04  DAS  5.00                                            */
/*      - Created.                                                   */
/*                                                                   */
/*    11/16/04  DAS  5.00a                                           */
/*      - Added library PIRHITS for Cheney.                          */
/*                                                                   */
/*    04/27/07  MLB  5.10                                            */
/*      - Revised SAVLIB cmd to *UNLOAD for TPC.                     */
/*    12/21/04  MLB  5.00b                                           */
/*      - Enh: Added override to prtf QPSAVOBJ to direct report      */
/*        to outq BFCBACKUP.                                         */
/*                                                                   */
/*    09/09/09  MLB  6.10                                            */
/*      - Enh: Added DSPJOBLOG *PRINT when backup fails to complete  */
/*        succcessfully.                                             */
/*                                                                   */
/*    03/30/12  MLB  6.40                                            */
/*      - Enh: Added cmd CHKTAP to program to verify that tape is    */
/*        loaded in the tape drive before allowing backup to proceed.*/
/*    05/08/12  MLB  6.40a                                           */
/*      - Enh: change to 6.40 mod. Added CHKTAP cmd with MONMSG for  */
/*        CPF6734 Seq. nbr not found on tape. This occurs for new    */
/*        tapes that have only been initialized.                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: City Line Distributors                  */
/*                                                                   */
/*    01/19/07  MLB  CLD                                             */
/*      - Revised program to add library SOCKETWS to daily backup.   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: TPC Foodservice                         */
/*                                                                   */
/*    11/08/16  MLB  TPC                                             */
/*      - Revised program to update libraries to be saved as part of */
/*        part of Dakota WMS v6.50 upgrade.                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Indianhead Foodservice                  */
/*                                                                   */
/*    03/04/09  MLB  IFD                                             */
/*      - Revised program to add library PIRVOICE to daily backup.   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Saval Foods                             */
/*                                                                   */
/*    08/25/09  MLB  SVL                                             */
/*      - Revised program to add library PIRVOICE to daily backup.   */
/*    09/05/09  MLB  SVLa                                            */
/*      - Revised program to use virtual tape device, TAPVRT01       */
/*        instead of TAP01.                                          */
/*    09/09/09  MLB  SVLb                                            */
/*      - Revised program to *REWIND instead of *UNLOAD because      */
/*        save uses virtual tape drive, TAPVRT01 which is linked     */
/*        to image catalog, BFCBKUP01. See cmd WRKIMGCLG *ALL.       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Halsey Foodservice                      */
/*                                                                   */
/*    10/12/09  MLB  HAL                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*    10/13/09  MLB  HALa                                            */
/*      - Revised program to use virtual tape device, TAPVRT01       */
/*        instead of TAP01.                                          */
/*    07/25/17  MLB  HALb                                            */
/*      - Revised program to add support for vendor Lastervault's    */
/*        backup application. Per Harley G. 07.25.17.                */
/*        New drive will be TAP02 instead of TAPVRT01.               */
/*      - Added libraries PIR, BFCGLOBALF to backup.                 */
/*      - NOTE: UBD references commented out so pgm will compile.    */
/*    07/26/17  MLB  HALc                                            */
/*      - Revised program to change ENDOPT(*UNLOAD).                 */
/*        Per Harley G. email 07.26.17                               */
/*    07/27/17  MLB  HALd                                            */
/*      - Revised program to change ENDOPT(*UNLOAD).                 */
/*        Per Harley G. email 07.26.17                               */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Packer's Provision                      */
/*                                                                   */
/*    10/12/09  MLB  PAK                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*      - Revised program to add library TMS / TMSF to daily backup. */
/*      - Add SAVCFG and SAVSECDTA cmds at very beginning.           */
/*      - Revised program to end subsystem QINTER before starting    */
/*        daily backup. QINTER will restarted after save is done.    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Coastal Sunbelt Produce                 */
/*                                                                   */
/*    04/20/10  MLB  CSP                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Capitol City Produce                    */
/*                                                                   */
/*    04/08/10  MLB  CCP                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*    05/03/10  MLB  CCPa                                            */
/*      - Revised program to end QINTER subsystem before starting    */
/*        the daily backup. The QINTER subsystem will be started     */
/*        after the backup is completed.                             */
/*      - Added library PIRTESTF to daily backup until CCP goes      */
/*        then PIRTESTF will be removed from the daily backup.       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: MJ Kellner                              */
/*                                                                   */
/*    09/23/10  MLB  MJK                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*    09/30/10  MLB  MJKa  Per Dave Rikas.                           */
/*      - Revised program to remove SAVCFG, SAVSECDTA cmds from      */
/*        daily backup.                                              */
/*      - Revised program to remove library PIR from daily backup.   */
/*      - Changed backup to use *END for sequence number and eject   */
/*        the backup tape.                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Eastland Foods                          */
/*                                                                   */
/*    05/12/11  MLB  EFC                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*    05/12/11  MLB  EFCa                                            */
/*      - Revised program to use virtual tape device, TAPVRT01       */
/*        instead of TAP01.                                          */
/*    02/23/16  MLB  EFCb                                            */
/*      - Revised program to add PIRF002, PIRF003 and PIRF004 to     */
/*        daily backup.                                              */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Inter County Bakers                     */
/*                                                                   */
/*    03/30/12  MLB  ICB                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Grave's Menu Maker                      */
/*                                                                   */
/*    05/02/12  MLB  GMM                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Agar Supply                             */
/*                                                                   */
/*    06/06/12  MLB  ASC                                             */
/*      - Set tape backup device to TAP01.                           */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*      - Revised 3 sav cmds that are part of ICB and 2 other        */
/*        clients backup to use &tapedevice instead of hard-coded    */
/*        backup device.                                             */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Reinhart Foodservice                    */
/*                                                                   */
/*    05/14/13  RTR  RFS                                             */
/*      - Added RFS to Agar/ICB save.                                */
/*      - Changed PIRF to PIRF* to get all warehouse libs.           */
/*    06/01/13  MLB  RFSa                                            */
/*      - Changed PIRMODS to PIRMODS* to get all warehouse libs.     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: HM Wagner                               */
/*                                                                   */
/*    09/17/12  MLB  HMW                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Kelly Foods                             */
/*                                                                   */
/*    09/28/12  MLB  KFS                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Get Fresh Sales                         */
/*                                                                   */
/*    02/22/13  MLB  GFS                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Greenleaf Produce                       */
/*                                                                   */
/*    04/01/13  MLB  GLP                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Presto Foods                            */
/*                                                                   */
/*    10/09/14  MLB  PFC                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*    06/24/15  MLB  PFCa                                            */
/*      - Revised program to set ENDOPT parm to *REWIND from *UNLOAD */
/*        when backup runs on Saturday. All other days, use *UNLOAD. */
/*    08/31/15  MLB  PFCb                                            */
/*      - Revised PFCa mod. Add Sunday to test to use *REWIND        */
/*        instead of *UNLOAD.                                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Harbor Wholesale                        */
/*                                                                   */
/*    05/10/17  MLB  HAR                                             */
/*      - Revised program to add library PIRVOICE to daily backup    */
/*        and SAVCFG and SAVSECDTA cmds at very beginning.           */
/*    05/10/17  MLB  HARa                                            */
/*      - Revised program to set ENDOPT parm to *REWIND from *UNLOAD.*/
/*      - Note: These backup mods are for the Dev box until the Prod */
/*              box DR/HA replication is ready on Prod box.          */
/*                                                                   */
/*-------------------------------------------------------------------*/

BFCTSAVLIB:  PGM        PARM(&CLIENT &MSGQ &RETURN)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Name of this program.                                           (640 A) */

             DCL        VAR(&PGM) TYPE(*CHAR) LEN(10) +
                          VALUE(BFCSAVLIB)                        /* (640 A) */

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&CLIENT)     TYPE(*CHAR) LEN(10)
             DCL        VAR(&TPC)        TYPE(*CHAR) LEN(10) value('TPC')
             DCL        VAR(&DAYOFWEEK)  TYPE(*CHAR) LEN(4)       /* (PFCaA) */
             DCL        VAR(&ENDOPT)     TYPE(*CHAR) LEN(10)      /* (PFCaA) */
             DCL        VAR(&MSGQ)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN)     TYPE(*CHAR) LEN(8)
             DCL        VAR(&TAPEDEVICE) TYPE(*CHAR) LEN(10)      /* (640 A) */
             DCL        VAR(&DATE) TYPE(*CHAR) LEN(6)             /* (HALbA) */
             DCL        VAR(&TIME) TYPE(*CHAR) LEN(6)             /* (HALbA) */
             DCL        VAR(&TYPE) TYPE(*CHAR) LEN(1) VALUE(D)    /* (HALbA) */
             DCL        VAR(&DATETIME) TYPE(*CHAR) LEN(13)        /* (HALbA) */
             DCL        VAR(&VOL)      TYPE(*CHAR) LEN(6)         /* (HALdA) */

             DCL        VAR(&ERRCNT)     TYPE(*DEC)  LEN(1 0)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)

             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(ERROR))

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             IF         COND(&CLIENT *EQ ' ') THEN(DO)
             RTVDTAARA  DTAARA(PIRCLIENT) RTNVAR(&CLIENT)
             ENDDO

             IF         COND(&MSGQ *EQ ' ') THEN(DO)
             CHGVAR     VAR(&MSGQ) VALUE('QSYSOPR')
             ENDDO

             RMVMSG     CLEAR(*ALL)
             RTVJOBA    DAYOFWEEK(&DAYOFWEEK)                     /* (PFCaA) */

/*  Direct report to BFCBACKUP outq.                                  (500b) */

             OVRPRTF    FILE(QPSAVOBJ) OUTQ(BFCBACKUP)             /* (500b) */

/*  Check that tape drive is ready.                                  (640 A) */

             SELECT                                               /* (640 A) */
             WHEN       COND(&CLIENT = 'HALSEY') Then(DO)         /* (HALbA) */
               CHGVAR     VAR(&TAPEDEVICE) VALUE('TAP02')         /* (HALbA) */
               CHGVAR     VAR(&VOL) VALUE('DAILY')                /* (HALdA) */
               RTVSYSVAL  SYSVAL(QDATE) RTNVAR(&DATE)             /* (HALbA) */
               RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIME)             /* (HALbA) */
               CHGVAR     VAR(&DATETIME) VALUE(&DATE *CAT &TIME *CAT +
                            &TYPE)                                /* (HALbA) */

               VRYCFG     CFGOBJ(TAP02) CFGTYPE(*DEV) STATUS(*ON) /* (HALbA) */

/*             ADDLIBLE   LIB(UBD)                                   (HALbA) */
/*             UBD/INZUBD DEV(TAP02) TAPIMG(&DATETIME) +
                          TAPVOL(DAILY)                              (HALbA) */
             ENDDO                                                /* (HALbA) */
                                                                  /* (HALbA) */
/*           WHEN       COND(&CLIENT = 'HALSEY' +                    (HALbD) */
             WHEN       COND(&CLIENT = 'EASTLAND' +
                         *or &CLIENT = 'SAVALFOODS') +
                          THEN(DO)                                /* (HALbM) */
               CHGVAR     VAR(&TAPEDEVICE) VALUE('TAPVRT01')      /* (640 A) */
               CHGVAR     VAR(&ENDOPT)     VALUE('*UNLOAD')       /* (PFCaA) */
             ENDDO                                                /* (640 A) */

             OTHERWISE  CMD(DO)                                   /* (640 A) */
               CHGVAR     VAR(&TAPEDEVICE) VALUE('TAP01')         /* (640 A) */
               CHGVAR     VAR(&ENDOPT)     VALUE('*UNLOAD')       /* (PFCaA) */
                                                                  /* (PFCaA) */
               IF         COND(&CLIENT = 'PRESTOFOOD') THEN(DO)   /* (PFCaA) */
/*               On Sat or Sun, just rewind tape.No one to chg tape. (PFCbM) */
                 IF         COND(&DAYOFWEEK = '*SAT' +
                            *OR  &DAYOFWEEK = '*SUN') THEN(DO)    /* (PFCbM) */
                   CHGVAR     VAR(&ENDOPT)     VALUE('*REWIND')   /* (PFCaA) */
                 enddo                                            /* (PFCaA) */
               enddo                                              /* (PFCaA) */
                                                                  /* (PFCaA) */
             ENDDO                                                /* (640 A) */
             ENDSELECT                                            /* (640 A) */

             CHKTAP     DEV(&TAPEDEVICE) SEQNBR(*FIRST) +
                          ENDOPT(*REWIND)                         /* (640aA)*/
             MONMSG     MSGID(CPF6734) EXEC(DO) /* Ignore seq# not +
                          found. New tape.                           (640aA) */
               GOTO StartSave                                     /* (640aA) */
             ENDDO                                                /* (640aA) */

             CHKTAP     DEV(&TAPEDEVICE) SEQNBR(*FIRST) +
                          ENDOPT(*REWIND)                         /* (640 A) */
             MONMSG     MSGID(CPF6708 CPF6718 CPF6720 CPF6734 +
                          CPF6737 CPF6751 CPF6760 CPF6772 CPF67E6 +
                          CPF9814) EXEC(DO)                       /* (640 A) */
               CHGVAR     VAR(&MSGDTA) VALUE(&PGM *TCAT ': Tape +
                            drive, ' *CAT &TAPEDEVICE *TCAT ' not +
                            ready. BFC Daily backup cancelled')   /* (640 A) */
               SNDPGMMSG  MSGID(CPF9898) MSGF(QSYS/QCPFMSG) +
                            MSGDTA(&MSGDTA) TOMSGQ(&MSGQ) MSGTYPE(*INFO)
               GOTO ERROR                                         /* (640 A) */
             ENDDO                                                /* (640 A) */

/*  Save libraries  */
StartSave:                                                        /* (640aA) */

   /* Special save for client DAVE */

             IF         COND(&CLIENT = 'DAVE') THEN(DO)
             SAVLIB     LIB(PIR900FDS PIRWORKDS SOCKETWS) DEV(TAP01) +
                          SEQNBR(1) TGTRLS(*CURRENT) +
                          CLEAR(*REPLACE) SAVACT(*SYNCLIB) +
                          SAVACTWAIT(120) SAVACTMSGQ(&MSGQ) +
                          OUTPUT(*PRINT)
             GOTO       CMDLBL(FINISHED)
             ENDDO

   /* Special save for client CHENEYBROS */

             IF         COND(&CLIENT = 'CHENEYBROS') THEN(DO)
             SAVLIB     LIB(PIRF PIRMODS PIRMODSCBI PIRHITS) +
                          DEV(TAP01) SEQNBR(1) TGTRLS(*CURRENT) +
                          CLEAR(*REPLACE) SAVACT(*SYNCLIB) +
                          SAVACTWAIT(120) SAVACTMSGQ(&MSGQ) +
                          OUTPUT(*PRINT)
             GOTO       CMDLBL(FINISHED)
             ENDDO

   /* Special save for client TPC */

             IF         COND(&CLIENT = &TPC) THEN(DO)
               SAVCFG     DEV(TAP01) SEQNBR(1) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVSECDTA  DEV(TAP01) SEQNBR(*END) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVLIB     LIB(PIRF PIRCSTM730 PIRMODS730 PIRVOICE PIR720 TPCSQL +
                            TPCSQLPGM BFCGLOTPCF) DEV(TAP01) +
                            SEQNBR(*END) ENDOPT(*UNLOAD) +
                            TGTRLS(*CURRENT) CLEAR(*REPLACE) +
                            SAVACT(*SYNCLIB) SAVACTWAIT(120) +
                            SAVACTMSGQ(&MSGQ) OUTPUT(*PRINT)
               GOTO       CMDLBL(FINISHED)
             ENDDO

   /* Special save for client City Line. */

             IF         COND(&CLIENT = 'CITYLINE') THEN(DO)
             SAVLIB     LIB(PIRF PIRMODS SOCKETWS) DEV(TAP01) +
                          SEQNBR(1) TGTRLS(*CURRENT) +
                          CLEAR(*REPLACE) SAVACT(*SYNCLIB) +
                          SAVACTWAIT(120) SAVACTMSGQ(&MSGQ) +
                          OUTPUT(*PRINT)
             GOTO       CMDLBL(FINISHED)
             ENDDO

   /* Special save for client Indianhead Foodservice. */

             IF         COND(&CLIENT = 'INDIANHEAD') THEN(DO)
               SAVLIB     LIB(PIR PIRF PIRMODS PIRVOICE PIRCSTM) +
                            DEV(TAP01) SEQNBR(1) ENDOPT(*UNLOAD) +
                            USEOPTBLK(*NO) TGTRLS(*CURRENT) +
                            CLEAR(*REPLACE) SAVACT(*SYNCLIB) +
                            SAVACTWAIT(120) SAVACTMSGQ(&MSGQ) +
                            ACCPTH(*YES) OUTPUT(*PRINT)
               GOTO       CMDLBL(FINISHED)
             ENDDO

   /* Special save for client Saval Foods                            (SVL A) */

             IF         COND(&CLIENT = 'SAVALFOODS') THEN(DO)     /* (SVL A) */
               SAVLIB     LIB(PIRF PIRMODS PIRVOICE PIRCSTM) +
                            DEV(TAPVRT01) SEQNBR(1) ENDOPT(*REWIND) +
                            USEOPTBLK(*NO) TGTRLS(*CURRENT) +
                            CLEAR(*REPLACE) SAVACT(*SYNCLIB) +
                            SAVACTWAIT(120) SAVACTMSGQ(&MSGQ) +
                            ACCPTH(*YES) OUTPUT(*PRINT)           /* (SVL A) */
               GOTO       CMDLBL(FINISHED)                        /* (SVL A) */
             ENDDO                                                /* (SVL A) */

   /* Special save for client Halsey Foodservice                     (HAL A) */

             IF         COND(&CLIENT = 'HALSEY') THEN(DO)         /* (HAL A) */
               SAVCFG     DEV(&TAPEDEVICE) SEQNBR(1) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVSECDTA  DEV(&TAPEDEVICE) SEQNBR(*END) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVLIB     LIB(PIR700 PIRF PIRMODS710 PIRVOICE PIRCSTM700 HALSQL +
                            HALSQLPGM BFCGLOHALF) DEV(&TAPEDEVICE) SEQNBR(*END) +
                            ENDOPT(*UNLOAD) USEOPTBLK(*NO) +
                            TGTRLS(*CURRENT) CLEAR(*REPLACE) +
                            SAVACT(*SYNCLIB) SAVACTWAIT(120) +
                            SAVACTMSGQ(&MSGQ) ACCPTH(*YES) +
                            OUTPUT(*PRINT) +
                            vol(&vol)                             /* (HALdA) */
               GOTO       CMDLBL(FINISHED)                        /* (HAL A) */
             ENDDO                                                /* (HAL A) */

   /* Special save for client Packer's Provision                     (PAK A) */

             IF         COND(&CLIENT = 'PACKERS') THEN(DO)        /* (PAK A) */
             ENDSBS     SBS(QINTER) OPTION(*IMMED) DELAY(30)
               SAVCFG     DEV(TAP01) SEQNBR(1) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVSECDTA  DEV(TAP01) SEQNBR(*END) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVLIB     LIB(PIRF PIRMODS PIRVOICE TMSF TMS) +
                            DEV(TAP01) SEQNBR(*END) ENDOPT(*REWIND) +
                            USEOPTBLK(*NO) TGTRLS(*CURRENT) +
                            CLEAR(*REPLACE) SAVACT(*SYNCLIB) +
                            SAVACTWAIT(120) SAVACTMSGQ(&MSGQ) +
                            ACCPTH(*YES) OUTPUT(*PRINT)           /* (PAK A) */
               GOTO       CMDLBL(FINISHED)                        /* (PAK A) */
             ENDDO                                                /* (PAK A) */

   /* Special save for client Coastal Sunbelt Produce                (CSP A) */

             IF         COND(&CLIENT = 'COASTALSUN') THEN(DO)     /* (CSP A) */
               SAVCFG     DEV(TAP01) SEQNBR(1) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVSECDTA  DEV(TAP01) SEQNBR(*END) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVLIB     LIB(PIR PIRF PIRMODS PIRVOICE PIRCSTM PIRSQL +
                            PIRSQLPGM) DEV(TAP01) SEQNBR(*END) +
                            ENDOPT(*REWIND) USEOPTBLK(*NO) +
                            TGTRLS(*CURRENT) CLEAR(*REPLACE) +
                            SAVACT(*SYNCLIB) SAVACTWAIT(120) +
                            SAVACTMSGQ(&MSGQ) ACCPTH(*YES) +
                            OUTPUT(*PRINT)                        /* (CSP A) */
               GOTO       CMDLBL(FINISHED)                        /* (CSP A) */
             ENDDO                                                /* (CSP A) */

   /* Special save for client Capitol City Produce.                  (CCP A) */

             IF         COND(&CLIENT = 'CAPITOLCTY') THEN(DO)     /* (CCP A) */
               ENDSBS     SBS(QINTER) OPTION(*IMMED) DELAY(30)    /* (CCPaA) */
               SAVCFG     DEV(TAP01) SEQNBR(1) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVSECDTA  DEV(TAP01) SEQNBR(*END) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVLIB     LIB(PIR PIRF PIRMODS PIRVOICE PIRCSTM PIRSQL +
                            PIRSQLPGM) DEV(TAP01) SEQNBR(*END) +
                            ENDOPT(*REWIND) USEOPTBLK(*NO) +
                            TGTRLS(*CURRENT) CLEAR(*REPLACE) +
                            SAVACT(*SYNCLIB) SAVACTWAIT(120) +
                            SAVACTMSGQ(&MSGQ) ACCPTH(*YES) +
                            OUTPUT(*PRINT)                        /* (CCP A) */
               GOTO       CMDLBL(FINISHED)                        /* (CCP A) */
             ENDDO                                                /* (CCP A) */

   /* Special save for client MJ Kellner                             (MJK A) */

             IF         COND(&CLIENT = 'MJKELLNER') THEN(DO)      /* (MJK A) */
               SAVLIB     LIB(PIRF PIRMODS PIRIFC30 PIRVOICE PIRCSTM) +
                            DEV(TAP01) SEQNBR(*END) +
                            ENDOPT(*UNLOAD) USEOPTBLK(*NO) +
                            TGTRLS(*CURRENT) CLEAR(*REPLACE) +
                            SAVACT(*SYNCLIB) SAVACTWAIT(60) +
                            SAVACTMSGQ(&MSGQ) ACCPTH(*YES) +
                            OUTPUT(*PRINT)                        /* (MJKaM) */
               GOTO       CMDLBL(FINISHED)                        /* (MJK A) */
             ENDDO                                                /* (MJK A) */

   /* Special save for client Eastland Foods                         (EFC A) */

             IF         COND(&CLIENT = 'EASTLAND') THEN(DO)       /* (EFC A) */
               SAVCFG     DEV(TAPVRT01) SEQNBR(1) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVSECDTA  DEV(TAPVRT01) SEQNBR(*END) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)
               SAVLIB     LIB(PIR PIRF PIRF002 PIRF003 PIRF004 PIRMODS +
                            PIRVOICE PIRCSTM PIRSQL PIRSQLPGM) +
                            DEV(TAPVRT01) SEQNBR(*END) +
                            ENDOPT(*REWIND) USEOPTBLK(*NO) +
                            TGTRLS(*CURRENT) CLEAR(*REPLACE) +
                            SAVACT(*SYNCLIB) SAVACTWAIT(120) +
                            SAVACTMSGQ(&MSGQ) ACCPTH(*YES) +
                            OUTPUT(*PRINT)                        /* (EFCbM) */
               GOTO       CMDLBL(FINISHED)
             ENDDO                                                /* (EFC A) */

   /* Special save for client Inter County Bakers                    (ICB A) */

/*           IF         COND(&CLIENT = 'ICB') THEN(DO)            /* (GMM D) */
             IF         COND(&CLIENT = 'ICB' +
                        *OR  &CLIENT = 'AGAR' +
                        *OR  &CLIENT = 'RFS ' +
                        *OR  &CLIENT = 'HMWAGNER' +
                        *OR  &CLIENT = 'KELLYS' +
                        *OR  &CLIENT = 'GETFRESH' +
                        *OR  &CLIENT = 'GREENLEAF' +
                        *OR  &CLIENT = 'PRESTOFOOD' +
                        *OR  &CLIENT = 'MENUMAKER') THEN(DO)      /* (RFSaM) */
               SAVCFG     DEV(&TAPEDEVICE) SEQNBR(1) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)                        /* (ASC M) */
               SAVSECDTA  DEV(&TAPEDEVICE) SEQNBR(*END) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)                        /* (ASC M) */
               SAVLIB     LIB(PIRF* PIRMODS* PIRVOICE PIRCSTM  PIR PIRSQL +
                            PIRSQLPGM) DEV(&TAPEDEVICE) SEQNBR(*END) +
                            ENDOPT(&ENDOPT) USEOPTBLK(*NO) +
                            TGTRLS(*CURRENT) CLEAR(*REPLACE) +
                            SAVACT(*SYNCLIB) SAVACTWAIT(120) +
                            SAVACTMSGQ(&MSGQ) ACCPTH(*YES) +
                            OUTPUT(*PRINT)                        /* (PFCaM) */
               GOTO       CMDLBL(FINISHED)                        /* (ICB A) */
             ENDDO                                                /* (ICB A) */

   /* Special save for client Harbor Wholesale - Dev Box             (HAR A) */

             IF         COND(&CLIENT = 'HARBOR') Then(do)         /* (HAR A) */
               CHGVAR     VAR(&ENDOPT)     VALUE('*LEAVE')        /* (HAR A) */
               SAVCFG     DEV(&TAPEDEVICE) SEQNBR(1) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)

               SAVSECDTA  DEV(&TAPEDEVICE) SEQNBR(*END) ENDOPT(*LEAVE) +
                            USEOPTBLK(*NO) CLEAR(*ALL) DTACPR(*YES) +
                            OUTPUT(*PRINT)

               SAVLIB     LIB(PIR* HAR* BFCGLOHARF) +
                            DEV(&TAPEDEVICE) SEQNBR(*END) +
                            ENDOPT(&ENDOPT) USEOPTBLK(*NO) +
                            TGTRLS(*CURRENT) CLEAR(*REPLACE) +
                            SAVACT(*SYNCLIB) SAVACTWAIT(120) +
                            SAVACTMSGQ(&MSGQ) ACCPTH(*YES) +
                            OUTPUT(*PRINT)                        /* (HAR A) */
               CHGVAR     VAR(&ENDOPT)     VALUE('*REWIND')       /* (HAR A) */

               SAV        DEV('/qsys.lib/tap01.devd') +
                            OBJ(('/Tomcat6036HAR11') +
                            ('/Tomcat6036HAR11/Logs/*' *OMIT) +
                            ('/Tomcat6036HAR11/BFCDakota/Logs/*' *OMIT)) +
                            SAVACT(*NO) SEQNBR(*END) ENDOPT(&ENDOPT) +
                            UPDHST(*YES) CLEAR(*ALL) DTACPR(*YES) /* (HAR A) */
               MONMSG     MSGID(CPF3837 CPF3794 CPF3808 CPF383A)  /* (HAR A) */

               CHGVAR     VAR(&ENDOPT)     VALUE('*LEAVE')        /* (HAR A) */
               GOTO       CMDLBL(FINISHED)                        /* (HAR A) */
             ENDDO                                                /* (HAR A) */

   /* Normal save for everyone else */

             SAVLIB     LIB(PIRF PIRMODS) DEV(TAP01) SEQNBR(1) +
                          TGTRLS(*CURRENT) CLEAR(*REPLACE) +
                          SAVACT(*SYNCLIB) SAVACTWAIT(120) +
                          SAVACTMSGQ(&MSGQ) OUTPUT(*PRINT)

/*  Save finished without error. Skip to sending back messages  */

 FINISHED:
             CHGVAR     VAR(&RETURN) VALUE('*OK')
             IF         COND(&CLIENT = 'PACKERS' *OR +
                             &CLIENT = 'CAPITOLCTY') THEN(DO)     /* (CCPaA) */
               STRSBS     SBSD(QINTER)                            /* (PAK A) */
               MONMSG     MSGID(CPF1010)                          /* (PAK A) */
             ENDDO                                                /* (PAK A) */
             GOTO       CMDLBL(GETOUT)

/*  Unexpected errors come here  */

 ERROR:
             CHGVAR     VAR(&RETURN) VALUE('*ERROR')
             OVRPRTF    FILE(QPJOBLOG) OUTQ(BFCBACKUP)            /* (610 A) */
             DSPJOBLOG  JOB(*) OUTPUT(*PRINT)                     /* (610 A) */
             IF         COND(&CLIENT = 'PACKERS' *OR +
                             &CLIENT = 'CAPITOLCTY') THEN(DO)     /* (CCPaA) */
               STRSBS     SBSD(QINTER)                            /* (PAK A) */
               MONMSG     MSGID(CPF1010)                          /* (PAK A) */
             ENDDO                                                /* (PAK A) */

/*  Receive any messages and pass them on  */

 GETOUT:

             CHGVAR     VAR(&ERRCNT) VALUE(&ERRCNT + 1)
             IF COND(&ERRCNT = 3) THEN(GOTO CMDLBL(BOTTOM))

 NEXTMSG:    DO
             RCVMSG     PGMQ(*SAME *) MSGQ(*PGMQ) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) SEV(&SEV) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             IF         COND(&MSGID *EQ ' ') THEN(GOTO CMDLBL(NOMSG))

             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) TOUSR(&MSGQ) MSGTYPE(*COMP)

             GOTO       CMDLBL(NEXTMSG)
             ENDDO
 NOMSG:

 BOTTOM:

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
