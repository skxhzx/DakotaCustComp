      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTQUALDS   Test qualified data structures
     *  16 January 2009
     *  Dave Sommerville
     *----------------------------------------------------------------
600dA
600dAD slrecds       e ds                  extname(slot)
600dAD frmSLREC        ds                  likeds(slrecds)
600dAD toSLREC         ds                  likeds(slrecds)
600dAD tstSLREC        ds                  likeds(frmSLREC)

      /free

         slwhse = 1;
         frmSLREC.slwhse = frmSLREC.slwhse;
         toSLREC.slwhse = toSLREC.slwhse;
         //slrecds.slwhse = slrecds.slwhse;

         *inlr = *on;

      /end-free
