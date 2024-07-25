      *===================================================================
      *
      *  Name .......... OELTXT_CBI
      *  Description ... OELTEXT field - Cheney Brothers
      *  Created by .... Max Blacknik
      *
      *-------------------------------------------------------------------
      * Revisions
      *
740 A *   03/26/20  MLB  7.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D oeltxt_cbi      ds

     D  oeltxt_base                 200
     D*                                    text('OELTEXT Field')

     D  cbioel_RFType                 2    overlay(oeltxt_base:191)
     D*                                    text('Runner Flag Type: RF')
     D  cbioel_RFStat                 1    overlay(oeltxt_base:193)
     D*                                    text('Runner Flag Status')
     D  cbioel_RFstrn                 7    overlay(oeltxt_base:194)
     D*                                    text('Runner Flag Selection Tran#')
