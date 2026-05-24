package com.yido.road.sos.component.storage;

import lombok.Data;

@Data
public class UploadResult {
	private String bucket;
	private String key;     // sos/…/file.jpg
	private String path;    // sos/…/
	private String name;    // file.jpg
	private long size;
	private String contentType;
	private String publicUrl;   // 바로 접근 가능한 URL
}
