package com.example.cuteapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class GlowupWaterWidget : AppWidgetProvider() {

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

            val views = RemoteViews(context.packageName, R.layout.glowup_water_widget)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

            // Read water data saved by Flutter
            val glasses = widgetData.getInt("water_glasses", 0)
            val goal = widgetData.getInt("water_goal", 8)
            val progress = if (goal > 0) (glasses * 100 / goal).coerceAtMost(100) else 0

            views.setTextViewText(R.id.water_count_text, "$glasses glass${if (glasses == 1) "" else "es"} today")
            views.setTextViewText(R.id.water_goal_text, "Goal: $goal")
            views.setProgressBar(R.id.water_progress_bar, 100, progress, false)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
