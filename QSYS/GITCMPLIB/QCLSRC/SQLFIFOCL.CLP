/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SQLFIFOCL   SQL stmts to display Pick slot out of FIFO rotation  */
/*  25 April 2007                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    04/25/07  DAS  5.10                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SQLFIFOCL:  PGM

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             MCSQL      STM('select slwhdp,sldisp,slitem from slot +
                          as s1  where s1.slpick=''Y'' and (select +
                          count(*) from slot as +
                          s2                        where s2.slwhse +
                          = s1.slwhse and s2.slitem = +
                          s1.slitem                           and +
                          (s2.slentd < s1.slentd or s2.slexpd < +
                          s2.slexpd) and s2.slpick = ''N'') > 0   +
                          order by slwhse,slwhdp,sldisp')

             ENDPGM
