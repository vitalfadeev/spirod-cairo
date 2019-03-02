module spiro_cairo;

import cairo.c.cairo;
import spiro;
import core.memory;

extern(C)
struct bezctx_cairo {
    bezctx base;    // This is a superclass of bezctx, and this is the entry for the base
    cairo_t* cr;
};

extern(C) {
void function(bezctx *bc, double x, double y, int is_open) moveto;
void function(bezctx *bc, double x, double y) lineto;
void function(bezctx *bc, double x1, double y1, double x2, double y2) quadto;
void function(bezctx *bc, double x1, double y1, double x2, double y2, double x3, double y3) curveto;
void function(bezctx *bc, int knot_idx) mark_knot;
}

extern(C)
void bezctx_cairo_moveto(bezctx *bc, double x, double y, int is_open) {
    cairo_t* cr = (cast(bezctx_cairo *)bc).cr;
    //cairo_line_to(cr, x, y);
    cairo_move_to(cr, x, y);
}

extern(C)
void bezctx_cairo_lineto(bezctx *bc, double x, double y) {
    cairo_t* cr = (cast(bezctx_cairo *)bc).cr;
    cairo_line_to(cr, x, y);
}

extern(C)
void bezctx_cairo_quadto(bezctx *bc, double x1, double y1, double x2, double y2) {
    cairo_t* cr = (cast(bezctx_cairo *)bc).cr;

    double x0, y0;
    cairo_get_current_point (cr, &x0, &y0);
    cairo_curve_to (cr,
                    2.0 / 3.0 * x1 + 1.0 / 3.0 * x0,
                    2.0 / 3.0 * y1 + 1.0 / 3.0 * y0,
                    2.0 / 3.0 * x1 + 1.0 / 3.0 * x2,
                    2.0 / 3.0 * y1 + 1.0 / 3.0 * y2,
                    y1, y2);

    //cairo_line_to(cr, x2, y2);
}

extern(C)
void bezctx_cairo_curveto(bezctx *bc, double x1, double y1, double x2, double y2, double x3, double y3) {
    cairo_t* cr = (cast(bezctx_cairo *)bc).cr;
    cairo_curve_to (cr, x1, y1, x2, y2, x3, y3);
    //cairo_line_to(cr, x3, y3);
}

extern(C)
void bezctx_cairo_knot(bezctx *bc, int knot_idx)  {
    //
}

@nogc
bezctx* bezctx_cairo_new(cairo_t* cr) {
    //bezctx_cairo *result = cast(bezctx_cairo *)core.memory.GC.malloc(bezctx_cairo.sizeof);
    bezctx_cairo *result = cast(bezctx_cairo *)core.memory.pureMalloc(bezctx_cairo.sizeof);

    result.base.moveto = &bezctx_cairo_moveto;
    result.base.lineto = &bezctx_cairo_lineto;
    result.base.quadto = &bezctx_cairo_quadto;
    result.base.curveto = &bezctx_cairo_curveto;
    result.base.mark_knot = &bezctx_cairo_knot;
    result.cr = cr;
    
    //return &(result.base);
    return cast(bezctx *)result;
}

@nogc
void bezctx_cairo_close(bezctx *z) {
    bezctx_cairo *bc = cast(bezctx_cairo *)z;

    //if (!bc.is_open) fprintf(bc->f, "z\n");
    
    //core.memory.GC.free(bc);
    core.memory.pureFree(bc);
}
