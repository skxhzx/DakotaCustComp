/*-------------------------------------------------------------------*/
/*                                                                   */
/*  RSTTOMWEB   STOP/START tomcat and webfacing                      */
/*  10 May 2010                                                      */
/*  Ginger Andrews                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    05/10/10  GJA  5.30                                            */
/*      - Created.  Drag&Drop is not closing connections.            */
/*                                                                   */
/*    08/03/12  MLB  6.40                                            */
/*      - Enh: Revised program to use new BFCTOMCAT cmd to stop/     */
/*        start the Tomcat servers.                                  */
/*                                                                   */
/*    03/09/13  DAS  6.50                                            */
/*      - Enh: Revised program to include PROD2                      */
/*    02/08/15  MLB  6.50a                                           */
/*      - Enh: Revised program to update BFCTOMCAT cmd for new parms.*/
/*                                                                   */
/*-------------------------------------------------------------------*/
 RSTTOMWEB:  PGM

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/
/* End WEBFACING */
             ENDTCPSVR  SERVER(*WEBFACING)

/* End TOMCAT */
/*           CALL PGM(ENDBFCTOMC)                                 /* (640 D) */
             BFCTOMCAT  CMD(*END) PROD(Y) PROD2(Y) TEST(Y) TEST2(N) +
                                                                  /* (650aM */
             MONMSG     MSGID(CPF0000)

             DLYJOB     DLY(900)      /*delay for 15 minutes*/

/* Start WEBFACING */
             STRTCPSVR  SERVER(*WEBFACING)

/* Start TOMCAT */
/*           CALL PGM(STRBFCTOMC)                                    (640 D) */
             BFCTOMCAT  CMD(*START) PROD(Y) PROD2(Y) TEST(Y) +
                          TEST2(N)                                /* (650aM) */
             MONMSG     MSGID(CPF0000)

             ENDPGM
