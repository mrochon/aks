using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Collections.Concurrent;
using System.Runtime.Versioning;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Configuration;

namespace FileLogger
{
    public sealed class FileLoggerConfiguration
    {
        public int EventId { get; set; }

        public string LogFilePath { get; set; }
    }

    public sealed class FileLogger : ILogger
    {
        private readonly string _name;
        private readonly Func<FileLoggerConfiguration> _getCurrentConfig;

        public FileLogger(
            string name,
            Func<FileLoggerConfiguration> getCurrentConfig) =>
            (_name, _getCurrentConfig) = (name, getCurrentConfig);

        public IDisposable? BeginScope<TState>(TState state) where TState : notnull => default!;

        public bool IsEnabled(LogLevel logLevel) => true;

        public void Log<TState>(
            LogLevel logLevel,
            EventId eventId,
            TState state,
            Exception? exception,
            Func<TState, Exception?, string> formatter)
        {
            if (!IsEnabled(logLevel))
            {
                return;
            }

            FileLoggerConfiguration config = _getCurrentConfig();
            if (config.EventId == 0 || config.EventId == eventId.Id)
            {
                var line = $"[{eventId.Id,2}: {logLevel,-12}] - {_name} - {formatter(state, exception)}";
                File.AppendAllLines(config.LogFilePath, new string[] { line });
            }
        }
    }

    [UnsupportedOSPlatform("browser")]
    [ProviderAlias("LocalFile")]
    public sealed class FileLoggerProvider : ILoggerProvider
    {
        private readonly IDisposable? _onChangeToken;
        private FileLoggerConfiguration _currentConfig;
        private readonly ConcurrentDictionary<string, FileLogger> _loggers =
            new(StringComparer.OrdinalIgnoreCase);

        public FileLoggerProvider(
            IOptionsMonitor<FileLoggerConfiguration> config)
        {
            _currentConfig = config.CurrentValue;
            _onChangeToken = config.OnChange(updatedConfig => _currentConfig = updatedConfig);
        }

        public ILogger CreateLogger(string categoryName) =>
            _loggers.GetOrAdd(categoryName, name => new FileLogger(name, GetCurrentConfig));

        private FileLoggerConfiguration GetCurrentConfig() => _currentConfig;

        public void Dispose()
        {
            _loggers.Clear();
            _onChangeToken?.Dispose();
        }
    }


    public static class FileLoggerExtensions
    {
        public static ILoggingBuilder AddFileLogger(
            this ILoggingBuilder builder)
        {
            builder.AddConfiguration();

            builder.Services.TryAddEnumerable(
                ServiceDescriptor.Singleton<ILoggerProvider, FileLoggerProvider>());

            LoggerProviderOptions.RegisterProviderOptions
                <FileLoggerConfiguration, FileLoggerProvider>(builder.Services);

            return builder;
        }

        public static ILoggingBuilder AddFileLogger(
            this ILoggingBuilder builder,
            Action<FileLoggerConfiguration> configure)
        {
            builder.AddFileLogger();
            builder.Services.Configure(configure);

            return builder;
        }
    }
}