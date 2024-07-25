      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO)
      *------------------------------------------------------------------*
      * Program:    DOCK001R                                             *
      * Date:       28/05/2021                                           *
      * Created By: Jitin Chopra                                         *
      * Called By:  DOCK001R                                             *
      * Purpose:    This program will read POSTATUS file and call        *
      *             DOCK002R for the records with status other than F & Y*
      *------------------------------------------------------------------*
     *  Revisions
     *
750  *    10/08/21  TDC  7.50
     *      - Added 'X' to POSTATUS filter
     *
770aA*    01/27/22  TDC  7.70a
     *      - Remove 'X' from POSTATUS filter
     *      - Decrease the number of rows to fetch to 175.
     *        The count was set to 200 but there were still a few errors
     *        being logged. Dropping th count by 25 should correct this.
     *
     *     * Note: The processes feeding POSTATUS have been changed to
     *       try to decrease the number of updates required.
     *                                                                  *
770bA*    03/08/23  DAS  7.70b                                          *
     *      - Moved H specs to top of program                           *
     *      - Removed HTTP BNDDIR                                       *
     *      - Added comments in definitions                             *
     *                                                                  *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D w_poswhs        s              3  0
     D w_pospo         s              9
     D TZ              s               Z

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D DOCK002R        PR                  EXTPGM('DOCK002R')
     D p_poswhs                       3  0
     D p_pospo                        9

     *----------------------------------------------------------------
     *  Status data structure
     *----------------------------------------------------------------

     D PsDs           SDS
     D  z_status         *Status
     D  z_job                244    253
     D  z_user               254    263
     D  z_job#               264    269  0

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

        Exsr DelcareCur;
        Exsr OpenCur;
        Exsr FetchCur;

        Dow sqlcode = *zeros;

          Exsr CallDOCK002R;
          Exsr FetchCur;

        Enddo;

        Exsr CloseCur;

        *Inlr = *On;

      *------------------------------------------------------------------*
      *Declare Cursor for POSTATUS to pick those with status = '0'       *
      *------------------------------------------------------------------*
        BegSr DelcareCur;

          Exec sql
            Declare PosCur cursor for
              Select POSWHS, POSPO
                from POSTATUS
750 D           //where POSSTAT not in ('F','Y');
770aD           //where POSSTAT not in ('F','Y','X')
770aA           where POSSTAT not in ('F','Y')
770aA
770aD           //fetch first 200 rows only;
770aA           fetch first 175 rows only;

        EndSr;

      *------------------------------------------------------------------*
      *Open Cursor for POSTATUS                                          *
      *------------------------------------------------------------------*
        BegSr OpenCur;

          Exec Sql
            Open PosCur;

        EndSr;

      *------------------------------------------------------------------*
      *Fetch Records of POSTATUS                                         *
      *------------------------------------------------------------------*
        BegSr FetchCur;

          Exec Sql
            Fetch PosCur into :w_poswhs, :w_pospo;

        EndSr;

        BegSr CloseCur;

          Exec Sql
            Close PosCur;

        EndSr;

      *------------------------------------------------------------------*
      *Call DOCK002R to create request and hit API                       *
      *------------------------------------------------------------------*
        BegSr CallDOCK002R;

          Callp DOCK002R(w_poswhs:w_pospo);

        EndSr;
