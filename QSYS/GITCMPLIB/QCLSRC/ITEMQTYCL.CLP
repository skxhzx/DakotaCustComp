/*-------------------------------------------------------------------*/
/*                                                                   */
/*  ITEMQTYCL Query to display Item qty exceptions                   */
/*  17 September 1999                                                */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  09/17/99  DAS  4.12                                              */
/*   - Created                                                       */
/*                                                                   */
/*-------------------------------------------------------------------*/

 ITEMQTYCL:  PGM

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/* Run query to get slot available quantities */

             RUNQRY     QRY(ITEMQTY1) QRYFILE((SLOT3))

/* Run query to get ItemQty available quantities */

             RUNQRY     QRY(ITEMQTY2) QRYFILE((ITEMQTY) (PIRITEM))

/* Run query to display exceptions (ItemQty avail <> Slot avail */

             RUNQRY     QRY(ITEMQTY3) QRYFILE((TMPQTY2) (TMPQTY1) +
                          (PIRITEM)) OUTTYPE(*DISPLAY)

             ENDPGM
