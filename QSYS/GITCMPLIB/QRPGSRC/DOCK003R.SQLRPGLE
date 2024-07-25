      /copy qcopysrc,hspecs
     Hdatfmt(*mdy)
      *------------------------------------------------------------------*
      * Program:    DOCK003R                                             *
      * Date:       08/10/2021                                           *
      * Created By: Jitin Chopra                                         *
      * Called By:  DOCK003R                                             *
      * Purpose:    This program will receive number of days as input    *
      *             and then delete records from DOCK001PA .             *
      *------------------------------------------------------------------*
      *  Revisions                                                       *
     *                                                                  *
770aA*    03/08/23  DAS  7.70a                                          *
     *      - Moved H specs to top of program                           *
     *      - Added comments in definitions                             *
     *                                                                  *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program prototype
     *----------------------------------------------------------------

     D DOCK003R        pr                  extpgm('DOCK003R')
     D p_Days                         3  0

     D DOCK003R        pi
     D p_Days                         3  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     DW_Date           s               d   datfmt(*mdy)

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /FREE

             W_Date = %Date() - %Days(p_Days);

             Exec Sql
               Delete from Dock001pa
                where date(pots) <= :W_Date;

             *Inlr = *On;

      /END-FREE
