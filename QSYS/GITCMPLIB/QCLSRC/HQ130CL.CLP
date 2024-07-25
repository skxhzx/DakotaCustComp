/*-------------------------------------------------------------------*/
/*                                                                   */
/*  HQ130CL   Run CPYFRMIMPF cmd for IMPFPQTY.                       */
/*  18 October 2007                                                  */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/

 HQ130CL:    PGM        PARM(&TYPE &MBR)


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MBR)        TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGDTA)     TYPE(*CHAR) LEN(256)
             DCL        VAR(&MSGF)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGFLIB)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&MSGID)      TYPE(*CHAR) LEN(7)
             DCL        VAR(&SEV)        TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&TYPE)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&UNQKEY)     TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Parameters:                                                      */
/*                                                                   */
/*    &TYPE  -  *PROD   Copy file to Production library, PIRF        */
/*              *TEST   Copy file to Test library, PIRTESTF          */
/*              *900    Copy file to 900 Test library, PIR900F.      */
/*    &MBR   -  Member name to copy file from/to IMPFPQTY.           */
/*                                                                   */
/*-------------------------------------------------------------------*/

/*  On with the show ... */


   /* Copy file to Production library. */

             IF         COND(&TYPE *EQ '*PROD') THEN(DO)
               CPYFRMIMPF FROMFILE(PIRTFR/IMPFPQTY &MBR) +
                            TOFILE(PIRF/IMPFPQTY &MBR) +
                            MBROPT(*REPLACE) RMVBLANK(*TRAILING) +
                            RPLNULLVAL(*FLDDFT)
             ENDDO

   /* Copy file to Test library. */

             IF         COND(&TYPE *EQ '*TEST') THEN(DO)
               CPYFRMIMPF FROMFILE(PIRTFR/IMPFPQTY &MBR) +
                            TOFILE(PIRTESTF/IMPFPQTY &MBR) +
                            MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)
             ENDDO

   /* Copy file to BFC 900 Test library. */

             IF         COND(&TYPE *EQ '*TEST') THEN(DO)
               CPYFRMIMPF FROMFILE(PIRTFR/IMPFPQTY &MBR) +
                            TOFILE(PIR900F/IMPFPQTY &MBR) +
                            MBROPT(*REPLACE) RPLNULLVAL(*FLDDFT)
             ENDDO


             ENDPGM
