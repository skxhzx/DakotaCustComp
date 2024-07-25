      *===================================================================
      *
      *  Name .......... OHMISC_NCH
      *  Description ... OHMISC field - Nicholas & Co.
      *  Created by .... Max Blacknik
      *
      *===================================================================
      * Revisions
      *
640 A *   03/14/11  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ohmisc_nch      ds

     D  nchmsc_base                  20
     D*                                    text('OHMISC Field')

     D  nchmsc_Date                   6    overlay(nchmsc_base:1)
     D*                                    text('Delivery Date')

     D  nchmsc_Sngplt                 3    overlay(nchmsc_base:7)
     D*                                    text('Single Pallet Pick')

     D  nchmsc_Subs                   1    overlay(nchmsc_base:10)
     D*                                    text('Customer Accepts Subs Y/N')

     D  nchmsc_Cid                    2    overlay(nchmsc_base:11)
     D*                                    text('Host Company ID')

     D  nchmsc_Whse                   2    overlay(nchmsc_base:13)
     D*                                    text('Host Warehouse Nbr')

     D  nchmsc_Pkzn                   6    overlay(nchmsc_base:15)
     D*                                    text('Single Pallet Pick Zone')
     D*                                    text('Blank=All or Pick Zone')
