package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.NotificationRecipient;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface NotificationRecipientMapper {
    List<NotificationRecipient> selectNotificationRecipientList(Map<String, Object> params);

    int selectNotificationRecipientCount(Map<String, Object> params);

    NotificationRecipient selectNotificationRecipient(@Param("recipientId") Long recipientId);

    void insertNotificationRecipient(NotificationRecipient recipient);

    void updateNotificationRecipient(NotificationRecipient recipient);

    void deleteNotificationRecipient(NotificationRecipient recipient);
}
