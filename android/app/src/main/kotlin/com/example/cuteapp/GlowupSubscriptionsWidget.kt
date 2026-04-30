package com.example.cuteapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class GlowupSubscriptionsWidget : AppWidgetProvider() {

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

            val views = RemoteViews(context.packageName, R.layout.glowup_subscriptions_widget)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

            // Read subscription data saved by Flutter
            val monthlyTotal = widgetData.getString("sub_monthly_total", "0.00")
            val currency = widgetData.getString("sub_currency", "€")
            val nextName = widgetData.getString("sub_next_name", null)
            val nextDays = widgetData.getInt("sub_next_days", -1)

            views.setTextViewText(R.id.sub_monthly_total, "$currency$monthlyTotal/month")

            if (nextName != null && nextDays >= 0) {
                val dueText = when (nextDays) {
                    0 -> "$nextName due today"
                    1 -> "$nextName due tomorrow"
                    else -> "$nextName due in $nextDays days"
                }
                views.setTextViewText(R.id.sub_next_due, dueText)
            } else {
                views.setTextViewText(R.id.sub_next_due, "No subscriptions yet")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
