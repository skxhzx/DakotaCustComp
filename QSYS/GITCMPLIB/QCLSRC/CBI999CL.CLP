/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CBI999CL  Delete 999 items virtual slots with zero qty           */
/*  26 September, 2001                                               */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Client Custom Revisions: Cheney Brothers                         */
/*                                                                   */
/*    01/16/15  MLB  CBI                                             */
/*      - Disabled CPYF of ZERO999 file. No longer populated.        */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CBI999CL:   PGM

/*-------------------------------------------------------------------*/

/*  On with the show ... */

/*           CPYF       FROMFILE(ZERO999) +
                        TOFILE(ZERO999BK) MBROPT(*REPLACE)           (CBI D) */
/*           MONMSG     MSGID(CPF2869 CPF2817)                    /* (CBI D) */

             CALL       PGM(CBI999)

/*           CLRPFM     FILE(ZERO999)                             /* (CBI D) */

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
