package com.yido.road.sos.component.storage;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "storage")
public class StorageProperties {
	private String endpoint;        // https://kr.object.ncloudstorage.com
	private String region;          // kr-standard
	private String accessKey;
	private String secretKey;
	private String bucket;
	private String publicBaseUrl;   // 예: https://{endpoint}/{bucket}/  또는 CDN 도메인
}