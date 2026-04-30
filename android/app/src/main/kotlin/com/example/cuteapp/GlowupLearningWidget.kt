package com.example.cuteapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class GlowupLearningWidget : AppWidgetProvider() {

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

            val views = RemoteViews(context.packageName, R.layout.glowup_learning_widget)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

            // Read learning data saved by Flutter
            val goalTitle = widgetData.getString("learning_goal_title", null)
            val done = widgetData.getInt("learning_done", 0)
            val total = widgetData.getInt("learning_total", 0)
            val progressPct = widgetData.getInt("learning_progress", 0)

            if (goalTitle != null) {
                views.setTextViewText(R.id.learning_goal_title, goalTitle)
                views.setTextViewText(R.id.learning_progress_text, "$progressPct%")

                if (total > 0) {
                    views.setTextViewText(R.id.learning_tasks_text, "$done/$total tasks • $progressPct%")
                    views.setViewVisibility(R.id.learning_tasks_text, android.view.View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.learning_tasks_text, android.view.View.GONE)
                }

                views.setProgressBar(R.id.learning_progress_bar, 100, progressPct, false)
            } else {
                views.setTextViewText(R.id.learning_goal_title, "No active goals 📖")
                views.setTextViewText(R.id.learning_progress_text, "0%")
                views.setViewVisibility(R.id.learning_tasks_text, android.view.View.GONE)
                views.setProgressBar(R.id.learning_progress_bar, 100, 0, false)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
