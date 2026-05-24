package com.yido.road.sos.util;

public class GridXY {
    public final int nx;
    public final int ny;
    public final double lat;
    public final double lng;

    public GridXY(int nx, int ny, double lat, double lng) {
        this.nx = nx;
        this.ny = ny;
        this.lat = lat;
        this.lng = lng;
    }
}