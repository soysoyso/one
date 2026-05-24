package com.yido.road.sos.component.storage;


import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;

import java.net.URI;

@Configuration
@RequiredArgsConstructor
@EnableConfigurationProperties(StorageProperties.class)
public class S3ClientConfig {

    private final StorageProperties props;

    @Bean(name = "ncpS3v2Client")
    @ConditionalOnMissingBean(name = "ncpS3v2Client")
    public S3Client ncpS3v2Client() {
        software.amazon.awssdk.services.s3.S3Configuration s3cfg =
                software.amazon.awssdk.services.s3.S3Configuration.builder()
                        .pathStyleAccessEnabled(true) // NCP는 path-style 필수
                        .build();

        return S3Client.builder()
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(props.getAccessKey(), props.getSecretKey())))
                .region(Region.of(props.getRegion()))
                .endpointOverride(URI.create(props.getEndpoint()))
                .serviceConfiguration(s3cfg)
                .build();
    }

    @Bean(name = "ncpS3v2Presigner")
    @ConditionalOnMissingBean(name = "ncpS3v2Presigner")
    public S3Presigner ncpS3v2Presigner() {
        software.amazon.awssdk.services.s3.S3Configuration s3cfg =
                software.amazon.awssdk.services.s3.S3Configuration.builder()
                        .pathStyleAccessEnabled(true)
                        .build();

        return S3Presigner.builder()
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(props.getAccessKey(), props.getSecretKey())))
                .region(Region.of(props.getRegion()))
                .endpointOverride(URI.create(props.getEndpoint()))
                .serviceConfiguration(s3cfg)
                .build();
    }
}
