/*-------------------------------------------------------------------*/
/*                                                                   */
/*  FIXSLTDTEC   Fix SLOTDTE file                                    */
/*  06 June 2006                                                     */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    06/06/06  DAS 5.10                                             */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 FIXSLTDTEC: PGM

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CALL       PGM(FIXSLTDTE)
             RCLRSC     LVL(*CALLER)

             ENDPGM
