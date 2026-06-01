package com.yido.road.sos.repository.main;

import com.yido.road.sos.model.NotificationRecipient;
import com.yido.road.sos.model.NotificationTemplateSetting;
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

    NotificationRecipient selectExistingNotificationRecipient(NotificationRecipient recipient);

    List<NotificationRecipient> selectActiveRecipientsForSend(Map<String, Object> params);

    NotificationTemplateSetting selectNotificationTemplateSetting(@Param("notificationType") String notificationType);

    List<NotificationTemplateSetting> selectNotificationTemplateSettingsByDept(@Param("deptCd") String deptCd);

    void insertNotificationTemplateSetting(NotificationTemplateSetting setting);

    void updateNotificationTemplateSetting(NotificationTemplateSetting setting);

    void insertNotificationRecipient(NotificationRecipient recipient);

    void updateNotificationRecipient(NotificationRecipient recipient);

    void deleteNotificationRecipient(NotificationRecipient recipient);
}
