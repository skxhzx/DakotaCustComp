/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PFILEINZ  Truck build picking labels - Export file init          */
/*  30 August 2000                                                   */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions:                                                       */
/*                                                                   */
/*    8/30/00  DAS  4.14                                             */
/*     - Created                                                     */
/*                                                                   */
/*    8/20/08  MLB  5.20                                             */
/*     - Enh: Added client custom code support.                      */
/*                                                                   */
/*    8/20/08  MLB  5.20a                                            */
/*     - Enh: Revised pgm to receive Route ID from calling pgm.      */
/*       Needed as part of client custom mod for Ettline.            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Ettline Foods                           */
/*                                                                   */
/*    8/20/08  MLB  ETT  P#00133                                     */
/*     - Program revised to NOT clear export member. Host pgm        */
/*       will ensure that member is cleared.                         */
/*     - Add call to new pgm, GETCLTMBR to retrieve mbr name         */
/*       from customer order to use for export.                      */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Chef's Warehouse/Dairyland              */
/*                                                                   */
/*   12/16/13  RTR  DRY                                              */
/*     - Added code to create unique member for EXPFPLBL.            */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Reinhart Foodservice                    */
/*                                                                   */
/*    6/10/13  RTR  RFSa                                             */
/*     - Changed to include 3 digit warehouse number in member       */
/*       name.                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*   Input                                                           */
/*                                                                   */
/*    &WHSE   -  Warehouse                                           */
/*    &RTE    -  Host route                                          */
/*    &RTID   -  BFC route ID                                 (520a) */
/*                                                                   */
/*   Output                                                          */
/*                                                                   */
/*    &MBR    -  Member name                                         */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Notes:                                                           */
/*                                                                   */
/*   This program will create/cleare a member in the export file.    */
/*   The member name to be used is the host route name.              */
/*                                                                   */
/*-------------------------------------------------------------------*/

/* PFILEINZ:   PGM        PARM(&WHSE &RTE &MBR)                      (520aD) */
 PFILEINZ:   PGM        PARM(&WHSE &RTE &MBR &RTID)               /* (520aD) */

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* Client ID's.    */                                           /* (520 A) */

             DCL        VAR(&ETTLINE) TYPE(*CHAR) LEN(10) +
                          VALUE('ETTLINE')                        /* (ETT A) */
             DCL        VAR(&RFS) TYPE(*CHAR) LEN(10) +
                          VALUE('RFS')                            /* (RFSaA) */
             DCL        VAR(&DAIRYLAND) TYPE(*CHAR) LEN(10) +
                          VALUE('DAIRYLAND')                      /* (DRY A) */

  /* Export files */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) +
                          VALUE('EXPFPLBL')

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&client)     TYPE(*CHAR) LEN(10)      /* (520 A) */
             DCL        VAR(&clientloc)  TYPE(*CHAR) LEN(10)      /* (520 A) */
             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&NXTNUM)     TYPE(*DEC)  LEN(7)
             DCL        VAR(&NXTNUMA)    TYPE(*CHAR) LEN(7)
             DCL        VAR(&RTE)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&RTID)       TYPE(*CHAR) LEN(5)       /* (520aA) */
             DCL        VAR(&WHSE)       TYPE(*CHAR) LEN(3)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Get Client ID */                                               /* (520 A) */
             CALL       PGM(GETCLIENT) PARM(&CLIENT &CLIENTLOC)   /* (520 A) */

/* Create member name */

             SELECT                                               /* (RFSaA) */
          /* IF         COND(&CLIENT = &ETTLINE) THEN(DO)         /* (RFSaD) */
             WHEN       COND(&CLIENT = &ETTLINE) THEN( +
               CALL GETCLTMBR PARM(&WHSE &RTID &RTE &MBR))        /* (RFSaM) */
          /* enddo                                                /* (RFSaD) */
             WHEN       COND(&CLIENT = &RFS) THEN(CHGVAR VAR(&MBR) +
                          VALUE('L' *CAT &WHSE *CAT &RTE))        /* (RFSaA) */
             WHEN       COND(&CLIENT = &DAIRYLAND) THEN(DO)       /* (DRY A) */
               CALL       PGM(PIRFTP#) PARM(&NXTNUM)              /* (DRY A) */
               CHGVAR     VAR(&NXTNUMA) VALUE(&NXTNUM)            /* (DRY A) */
               CHGVAR     VAR(&MBR) VALUE('R' *CAT %SST(&WHSE 2 2) +
                            *CAT &NXTNUMA)                        /* (DRY A) */
             ENDDO                                                /* (DRY A) */
        /*   ELSE       CMD(DO)    */                             /* (RFSaD) */
             OTHERWISE  CMD(CHGVAR VAR(&MBR) VALUE('L' *CAT +
                          %SST(&WHSE 2 2) *CAT &RTE))             /* (RFSAM) */
             ENDSELECT                                            /* (RFSaM) */

/* Create/Clear member in export file */

             CHKOBJ     OBJ(&FILE) OBJTYPE(*FILE) MBR(&MBR)
             MONMSG     MSGID(CPF9815) EXEC(ADDPFM FILE(&FILE) +
                          MBR(&MBR))
             IF         COND(&CLIENT = &ETTLINE) THEN(DO)         /* (ETT A) */
/*             Do not clear mbr. Host pgm will clear/rmv mbr.        (ETT A) */
             enddo                                                /* (ETT A) */
             ELSE       CMD(DO)
             CLRPFM     FILE(&FILE) MBR(&MBR)
             enddo                                                /* (ETT A) */

             ENDPGM
