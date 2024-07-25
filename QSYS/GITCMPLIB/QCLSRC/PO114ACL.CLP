/*-------------------------------------------------------------------*/
/*                                                                   */
/*  PO114ACL  PO delete (Stand alone)                                */
/*  27 July, 2000                                                    */
/*  Hemant Kapadia                                                   */
/*   - Created                                                       */
/*                                                                   */
/*   This is a CALL program created for CBI because their version of */
/*   PO program PO110 does not allow delete option. This program will*/
/*   have to be executed by typing the command CALL PO114ACL.        */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*                                                                   */
/*                                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 PO114ACL:   PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/


/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/


/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/


/*  On with the show ... */

             CALL       PGM(PO114A)


/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
