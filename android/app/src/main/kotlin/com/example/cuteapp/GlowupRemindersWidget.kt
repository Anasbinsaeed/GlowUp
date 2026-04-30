package com.example.cuteapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class GlowupRemindersWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)

            val views = RemoteViews(context.packageName, R.layout.glowup_reminders_widget)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

            // Read reminder data saved by Flutter
            val count = widgetData.getInt("reminder_count", 0)
            val r1 = widgetData.getString("reminder_1", null)
            val r2 = widgetData.getString("reminder_2", null)
            val r3 = widgetData.getString("reminder_3", null)

            views.setTextViewText(R.id.widget_count, "$count reminder${if (count == 1) "" else "s"}")

            if (r1 != null) {
                views.setTextViewText(R.id.reminder_1, r1)
                views.setViewVisibility(R.id.reminder_1, android.view.View.VISIBLE)
            } else {
                views.setTextViewText(R.id.reminder_1, "No upcoming reminders 🎉")
                views.setViewVisibility(R.id.reminder_1, android.view.View.VISIBLE)
            }

            if (r2 != null) {
                views.setTextViewText(R.id.reminder_2, r2)
                views.setViewVisibility(R.id.reminder_2, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.reminder_2, android.view.View.GONE)
            }

            if (r3 != null) {
                views.setTextViewText(R.id.reminder_3, r3)
                views.setViewVisibility(R.id.reminder_3, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.reminder_3, android.view.View.GONE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
