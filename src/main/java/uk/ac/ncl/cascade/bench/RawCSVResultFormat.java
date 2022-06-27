package uk.ac.ncl.cascade.bench;

import org.openjdk.jmh.infra.BenchmarkParams;
import org.openjdk.jmh.results.BenchmarkResult;
import org.openjdk.jmh.results.IterationResult;
import org.openjdk.jmh.results.Result;
import org.openjdk.jmh.results.RunResult;
import org.openjdk.jmh.results.format.ResultFormat;

import java.io.PrintStream;
import java.util.Collection;
import java.util.Iterator;
import java.util.SortedSet;
import java.util.TreeSet;

/**
 * Creates a csv file that contains the raw measurements of each iteration when running each benchmark.
 */
public class RawCSVResultFormat implements ResultFormat {

    private final PrintStream out;
    private final String delimiter;

    public RawCSVResultFormat(PrintStream out, String delimiter) {
        this.out = out;
        this.delimiter = delimiter;
    }

    @Override
    public void writeOut(Collection<RunResult> results) {
        SortedSet<String> params = new TreeSet<>();
        for (RunResult res : results) {
            params.addAll(res.getParams().getParamsKeys());
        }

        printHeader(params);

        for (RunResult rr : results) {
            BenchmarkParams benchParams = rr.getParams();
            Iterator<BenchmarkResult> res = rr.getBenchmarkResults().iterator();
            while (res.hasNext()){
                BenchmarkResult benchmarkResult = res.next();
                Iterator<IterationResult> iterationResults = benchmarkResult.getIterationResults().iterator();

                while (iterationResults.hasNext()){
                    IterationResult iterationResult = iterationResults.next();                      printLine(benchParams.getBenchmark(), benchParams, params, iterationResult);
                }
            }


//            for (String label : rr.getSecondaryResults().keySet()) {
//                Result subRes = rr.getSecondaryResults().get(label);
//                printLine(benchParams.getBenchmark() + ":" + subRes.getLabel(), benchParams, params, subRes);
//            }
        }
    }

    private void printHeader(SortedSet<String> params) {
        out.print("\"Benchmark\"");
        out.print(delimiter);
        out.print("\"Mode\"");
        out.print(delimiter);
//        out.print("\"Threads\"");
//        out.print(delimiter);
//        out.print("\"Samples\"");
//        out.print(delimiter);
        out.print("\"Score\"");
        out.print(delimiter);
//        out.printf("\"Score Error (%.1f%%)\"", 99.9);
//        out.print(delimiter);
        out.print("\"Unit\"");
        for (String k : params) {
            out.print(delimiter);
            out.print("\"Param: " + k + "\"");
        }
        out.print("\r\n");
    }

    private void printLine(String label, BenchmarkParams benchmarkParams, SortedSet<String> params, IterationResult result) {
        out.print("\"");
        out.print(label);
        out.print("\"");
        out.print(delimiter);
        out.print("\"");
        out.print(benchmarkParams.getMode().longLabel());
        out.print("\"");
        out.print(delimiter);
//        out.print(emit(benchmarkParams.getThreads()));
//        out.print(delimiter);
//        out.print(emit(result.getPrimaryResult().getSampleCount()));
//        out.print(delimiter);
        out.print("\"");
        out.print(emit(result.getPrimaryResult().getScore()));
        out.print("\"");
//        out.print(delimiter);
//        out.print(emit(result.getPrimaryResult().getScoreError()));
        out.print(delimiter);
        out.print("\"");
        out.print(result.getScoreUnit());
        out.print("\"");

        for (String p : params) {
            out.print(delimiter);
            String v = benchmarkParams.getParam(p);
            if (v != null) {
                out.print("\"");
                out.print(emit(v));
                out.print("\"");
            }
        }

        out.print("\r\n");
    }

    private String emit(String v) {
        if (v.contains(delimiter) || v.contains(" ") || v.contains("\n") || v.contains("\r") || v.contains("\"")) {
            return "\"" + v.replaceAll("\"", "\"\"") + "\"";
        } else {
            return v;
        }
    }

    private String emit(int i) {
        return emit(String.format("%d", i));
    }

    private String emit(long l) {
        return emit(String.format("%d", l));
    }

    private String emit(double d) {
        return emit(String.format("%f", d));
    }

}

