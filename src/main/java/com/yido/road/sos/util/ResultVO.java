package com.yido.road.sos.util;

import lombok.Data;

@Data
public class ResultVO {
	private String code = "0000";
	private String message = "";
	private Object data;
	private Object data2;
	private Object sub;

}
