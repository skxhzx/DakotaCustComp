     h/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  GETGLORTE     Get GLORTELOG route info
     *  01 August 2017
     *  Rod Roller
     *
710  *    08/01/17  RTR  7.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *

     *----------------------------------------------------------------
     *  Standard variables and constants
     *
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     * Program info data structure
     *
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Program Variables
     *
     d pWhse           s              3p 0
     d holdstamp       s               z
     d indstamp        s              5i 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhseA     - Warehouse Alpha
     *      pBranch    - Branch
     *      pRouteID   - Route ID
     *      pGroup     - Group Code
     *      pSubGroup  - Sub Group
     *      pType      - Type
     *
     *    Returned Parameters
     *
     *      pTotMins   - Total Minutes (Type = 2,3,4 only)
     *      pAddTS     - Add Timestamp
     *      pAddUCTS   - Add UC Timestamp
     *      pCurrUser  - Current User
     *      pJobUser   - Job User
     *      pJobName   - Job Name
     *      pJobNumber - Job Number
     *      pProgram   - Program
     *      pReturn    - *OK, *ERROR, *NOTFOUND
     *
     *----------------------------------------------------------------
     d main            pr                  extpgm('GETGLORTE')
     d* Input
     d   pWhseA                       3    const
     d   pBranch                      2    const
     d   pRouteID                     5    const
     d   pGroup                      10    const
     d   pSubGroup                   12    const
     d   pType                        1    const
     d* Output
     d   pTotMins                     5
     d   pAddTS                      26
     d   pAddUCTS                    26
     d   pCurrUser                   10
     d   pJobUser                    10
     d   pJobName                    10
     d   pJobNumber                   6
     d   pProgram                    10
     d   pReturn                     10

     D main            pi
     d* Input
     d   pWhseA                       3    const
     d   pBranch                      2    const
     d   pRouteID                     5    const
     d   pGroup                      10    const
     d   pSubGroup                   12    const
     d   pType                        1    const
     d* Output
     d   pTotMins                     5
     d   pAddTS                      26
     d   pAddUCTS                    26
     d   pCurrUser                   10
     d   pJobUser                    10
     d   pJobName                    10
     d   pJobNumber                   6
     d   pProgram                    10
     d   pReturn                     10

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------
      /free

        monitor;
          pWhse = %dec(pWhseA:3:0);
        on-error;
          pWhse = 1;
        endmon;

        exec sql select max(grladdts) into :holdstamp indicator :indstamp
                   from GLORTELOG
                  where grlwhse    = :pWhse
                    and grlbrnch   = :pBranch
                    and grlrtid    = :pRouteID
                    and grlgrpcode = :pGroup
                    and grlsubgrp  = :pSubGroup
                    and grltype    = :pType;

        exec sql select grltim, grladdts, grladduc, grlcurusr,
                        grljobusr, grljob, grljobnbr, grlpgm
                   into :pTotMins, :pAddTS, :pAddUCTS, :pCurrUser,
                        :pJobUser, :pJobName, :pJobNumber, :pProgram
                   from GLORTELOG
                  where grlwhse    = :pWhse
                    and grlbrnch   = :pBranch
                    and grlrtid    = :pRouteID
                    and grlgrpcode = :pGroup
                    and grlsubgrp  = :pSubGroup
                    and grltype    = :pType
                    and grladdts   = :holdstamp;

        select;
          when sqlstt = sqlsuccess;
            pReturn = '*OK';
          when sqlstt = sqlNoData;
            pReturn = '*NOTFOUND';
          other;
            pReturn = '*ERROR';
        endsl;

        *inlr = *on;
        return;
      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *  *INZSR   Initialization Subroutine
     *----------------------------------------------------------------
      /free
        begsr *inzsr;

        endsr;
      /end-free

