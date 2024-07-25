      *===================================================================
      *
      *  Name .......... ORDHM1_DTS
      *  Description ... Order Header Misc. Field 1 - DTS (DataTech IFC)
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/08/11  MLB  6.40
      *     - Created.
640aA *   05/20/11  MLB  6.40a
      *     - Enh: Added customer store# from MFCUSMSC, positions 213,5.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D ordhm1_dts      ds

     D  dtshm1_base                  40
     D*                                    text('Header Misc 1 Field')
     D*                                    text('OHMISC Field')

640 AD  dtshm1_cmst#                  5    overlay(dtshm1_base:1)
640 AD*                                    text('Customer Store#')
