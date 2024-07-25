/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PR310CL   Pending priority replenishments before import          */
/*  18 September, 2000                                               */
/*  Hemant Kapadia                                                   */
/*                                                                   */
/*  Revisions:                                                       */
/*  12/09/01  MLB  4.16a                                             */
/*    - Revised OPNQRYF to select only records with PRFLAG = 'S'.    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PR310CL:    PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/



/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


   /* Create selection criteria string. */


             OPNQRYF    FILE((PRPLFIL)) QRYSLT('PRFLAG = "S"') +
                          KEYFLD((PRWHDP) (PRTAIL))

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */

             OVRDBF     FILE(PRPLFIL) SHARE(*YES)


/*  On with the show ... */

REPEAT:
             CALL       PGM(PR312)

DONE:
/*  Clean up before leaving */

             CLOF       OPNID(PRPLFIL)
             DLTOVR     FILE(PRPLFIL)
             RCLRSC     LVL(*CALLER)

             ENDPGM
