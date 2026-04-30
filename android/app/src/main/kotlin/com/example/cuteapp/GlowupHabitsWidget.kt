package com.example.cuteapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class GlowupHabitsWidget : AppWidgetProvider() {

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

            val views = RemoteViews(context.packageName, R.layout.glowup_habits_widget)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

            // Read habit data saved by Flutter
            val done = widgetData.getInt("habits_done", 0)
            val total = widgetData.getInt("habits_total", 0)
            val progress = if (total > 0) (done * 100 / total) else 0
            val h1 = widgetData.getString("habit_1", null)
            val h2 = widgetData.getString("habit_2", null)

            views.setTextViewText(R.id.habit_progress_text, "$done/$total done")
            views.setProgressBar(R.id.habit_progress_bar, 100, progress, false)

            if (h1 != null) {
                views.setTextViewText(R.id.habit_1, h1)
            } else {
                views.setTextViewText(R.id.habit_1, "No habits yet 🥺")
            }

            if (h2 != null) {
                views.setTextViewText(R.id.habit_2, h2)
                views.setViewVisibility(R.id.habit_2, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.habit_2, android.view.View.GONE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
